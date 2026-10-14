"""Check source-labelled landmark directions in the exact displayed GLBs."""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import math
import pathlib
import struct

from glb_inventory import read_glb

ROOT = pathlib.Path(__file__).resolve().parents[1]


def binary_chunk(data: bytes) -> bytes:
    offset, chunks = 12, []
    while offset < len(data):
        size, kind = struct.unpack_from('<II', data, offset)
        offset += 8
        if kind == 0x004E4942:
            chunks.append(data[offset:offset + size])
        offset += size
    if len(chunks) != 1:
        raise ValueError('Expected one embedded geometry buffer')
    return chunks[0]


def center(document: dict, binary: bytes, record: dict) -> list[float]:
    minimum, maximum = [math.inf] * 3, [-math.inf] * 3
    for index in record['mesh_nodes']:
        node = document['nodes'][index]
        if any(key in node for key in ['translation', 'rotation', 'scale', 'matrix']):
            raise ValueError('Orientation audit requires original shared-frame vertices')
        for primitive in document['meshes'][node['mesh']]['primitives']:
            accessor = document['accessors'][primitive['attributes']['POSITION']]
            if accessor['componentType'] != 5126 or accessor['type'] != 'VEC3' or 'sparse' in accessor:
                raise ValueError('Expected explicit float32 positions')
            view = document['bufferViews'][accessor['bufferView']]
            stride = view.get('byteStride', 12)
            start = view.get('byteOffset', 0) + accessor.get('byteOffset', 0)
            count = accessor['count']
            end = start + (count - 1) * stride + 12
            if count <= 0 or stride < 12 or stride % 4 or view.get('buffer', 0) != 0 or end > len(binary) or end > view.get('byteOffset', 0) + view['byteLength']:
                raise ValueError('Position layout exceeds its geometry buffer')
            for number in range(count):
                point = struct.unpack_from('<3f', binary, start + number * stride)
                if not all(math.isfinite(v) for v in point):
                    raise ValueError('Nonfinite source position')
                minimum = [min(a, b) for a, b in zip(minimum, point)]
                maximum = [max(a, b) for a, b in zip(maximum, point)]
    if not all(math.isfinite(v) for v in minimum + maximum):
        raise ValueError('Landmark has no supplied geometry')
    return [(a + b) / 2 for a, b in zip(minimum, maximum)]


def audit_reference(reference: dict, root: pathlib.Path = ROOT) -> dict:
    path = root / reference['asset_path']
    data = path.read_bytes()
    if len(data) != reference['bytes'] or hashlib.sha256(data).hexdigest() != reference['sha256']:
        raise ValueError('Source differs from its pinned fingerprint')
    document = read_glb(path)
    if any(any(key in node for key in ['translation', 'rotation', 'scale', 'matrix']) for node in document['nodes']):
        raise ValueError('Orientation audit does not guess transformed source frames')
    binary = binary_chunk(data)
    observations, centers = [], {}

    def landmark(field: str, value: str) -> dict:
        matches = [row for row in reference['structures'] if row.get(field) == value]
        if len(matches) != 1:
            raise ValueError('Landmark must have one source identity: ' + value)
        record = matches[0]
        if record['id'] not in centers:
            centers[record['id']] = {'source_name': record['source_name'], 'center_metres': center(document, binary, record)}
        return record

    def check(name: str, axis: int, positive: tuple, negative: tuple) -> None:
        first, second = landmark(*positive), landmark(*negative)
        gap = centers[first['id']]['center_metres'][axis] - centers[second['id']]['center_metres'][axis]
        if gap <= 0.005:
            raise ValueError('Source landmark contradicts the proposed direction: ' + name)
        observations.append({'check': name, 'axis': 'XYZ'[axis], 'positive': first['id'], 'negative': second['id'], 'gap_metres': gap})

    check('left/right femurs', 0, ('label', 'Left femur'), ('label', 'Right femur'))
    check('left patella ahead of femur centre', 2, ('label', 'Left patella'), ('label', 'Left femur'))
    check('right patella ahead of femur centre', 2, ('label', 'Right patella'), ('label', 'Right femur'))
    if reference.get('study'):
        check('frontal/occipital bones', 2, ('label', 'Frontal bone'), ('label', 'Occipital bone'))
        check('head above femur', 1, ('label', 'Frontal bone'), ('label', 'Left femur'))
    else:
        prefix = 'VH_F_' if reference['id'] == 'female' else 'VH_M_'
        check('left/right lungs', 0, ('label', 'Left lung'), ('label', 'Right lung'))
        check('left/right kidneys', 0, ('label', 'Left kidney'), ('label', 'Right kidney'))
        check('left/right eyes', 0, ('source_name', prefix + 'eye_L'), ('source_name', prefix + 'eye_R'))
        for side in ['L', 'R']:
            check('eye/occipital pole ' + side, 2, ('source_name', prefix + 'eye_' + side), ('source_name', 'Allen_occipital_pole_' + side))
        check('head above femur', 1, ('source_name', prefix + 'eye_L'), ('label', 'Left femur'))
    return {'source_sha256': reference['sha256'], 'source_bytes': reference['bytes'],
            'left': [1, 0, 0], 'superior': [0, 1, 0], 'anterior': [0, 0, 1],
            'landmarks': centers, 'checks': observations}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='Write audited runtime metadata and retained measurements')
    parser.add_argument('--client-date', type=datetime.date.fromisoformat, default=datetime.date.today(),
                        help='Client-local audit date (YYYY-MM-DD); defaults to the executing machine date')
    args = parser.parse_args()
    references = json.loads((ROOT / 'content/sample_pack.json').read_text())['bodies']
    references.append(json.loads((ROOT / 'content/bodyparts3d_bone_study.json').read_text()))
    results = {reference['id']: audit_reference(reference) for reference in references}
    runtime = {'schema_version': 1, 'review_status': 'source geometry checked; medical review pending',
               'references': {key: {field: value for field, value in record.items() if field in ['source_sha256', 'left', 'superior', 'anterior']} for key, record in results.items()}}
    audit = {'schema_version': 1, 'client_date': args.client_date.isoformat(), 'method': 'AABB centres computed from actual float32 POSITION vertices; signed source-labelled landmark differences exceed 5 mm.',
             'references': results, 'limits': 'Technical direction corroboration only; no medical review, inter-body registration or completeness claim.',
             'bodyparts3d_coordinate_diagram': {'url': 'https://dbarchive.biosciencedbc.jp/data/bodyparts3d/20130619/coordinate_system.png',
                 'sha256': '338736275c11eac8c89531fdc14193c9a8adf5baab674033d9d89259f152a5f6',
                 'interpretation': 'Original +X left, +Y posterior, +Z superior. Existing [x,z,-y]*0.001 conversion gives displayed +X left, +Y superior, +Z anterior.'}}
    if args.write:
        (ROOT / 'content/reference_frames.json').write_text(json.dumps(runtime, indent=2) + '\n')
        (ROOT / 'docs/audit/reference-orientation.json').write_text(json.dumps(audit, indent=2) + '\n')
    for key, record in results.items():
        print('PASS source direction checks:', key, '·', len(record['checks']), 'landmark comparisons')


if __name__ == '__main__':
    main()

# Source direction checks

The displayed references support the same direction vectors: body-left `+X`,
superior `+Y`, anterior `+Z`. These are source-frame directions, independent of
camera rotation or inspection displacement. Left/right refer to the body's sides.

[audit_orientation.py](../../tools/audit_orientation.py) verifies the exact source
fingerprints and reads actual float32 position vertices. It compares AABB centres
for source-labelled paired femurs, patellae, lungs, kidneys and eyes, head/lower-body
landmarks, and eye/occipital or frontal/occipital landmarks. It rejects missing or
ambiguous records, transformed source frames and contradicted axis directions.
It does not use authored accessor bounds as its measurements.

All 23 signed comparisons exceed the 5 mm audit threshold: nine per HRA reference
and five for the separate bone study. [Retained measurements](reference-orientation.json)
include source identities, centres and gaps. Reproduce them with:

```sh
python3 tools/audit_orientation.py
```

`--write` regenerates both the measurements and
[runtime reference frames](../../content/reference_frames.json). A changed source
fingerprint requires a fresh audit before orientation is offered.

BodyParts3D's official [coordinate diagram](https://dbarchive.biosciencedbc.jp/data/bodyparts3d/20130619/coordinate_system.png)
places its original left, posterior and superior directions along positive X, Y
and Z. The existing `[x,z,-y]*0.001` conversion therefore produces the displayed
directions above. The inspected image is 28,425 bytes, SHA-256
`338736275c11eac8c89531fdc14193c9a8adf5baab674033d9d89259f152a5f6`.
HRA direction signs are inferred from the measured source-labelled landmarks;
the audit does not assert a published universal HRA coordinate convention.

These checks corroborate technical orientation. They do not constitute qualified
medical review, body registration, source-name correction or complete anatomical
validation. Original geometry, transforms and source licences are unchanged.

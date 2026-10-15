Legacy notebooks
================

These notebooks predate the current interface, `OsculatingInspiral`, and are kept for reference. Their outputs have
been removed. They are not maintained, and the last two no longer run.

- `tutorial.nb`: the tutorial for the earlier functions (`SchwarzOsculatingOrbitalElements`,
  `KerrOsculatingOrbitalElements`, `GenericKerrpexBL`, ...), which still work but are legacy. Two bugs were fixed when
  it moved here: the ELK comparison used an undefined `ELKup`, and the 3D plot had sin θ and cos θ swapped. The current
  tutorial is in the package documentation.
- `Data generation.nb`: a research script that generated inspirals for a parameter study. It calls
  `KerrOsculatingOrbitalElementsTPVecLessArg1`, which no longer exists, and writes files to a path on the author's
  computer.
- `TestingELKvspex.nb`: an early comparison of the ELK and pex equations. It calls `KerrOsculatingOrbitalElementsTP`,
  which no longer exists.

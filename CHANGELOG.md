# Changelog

## [0.1.0] — 2026-08-17

**This is a `0.x` line.** Minor releases may break API while the package
stabilises; patch releases stay source-compatible. Pin with
`.upToNextMinor(from:)` rather than `from:` — SwiftPM reads `from: "0.1.0"`
as `0.1.0 ..< 1.0.0`, which would accept a breaking `0.2.0` without asking.

- Initial package: `@CanonicalSum`, the attached-macro vehicle of the Swift
  ceremony killer. It derives the canonical `{"case": …, "value": …}`
  `Codable` conformance for a sum type (the framework's serialization
  contract, §4), so a feature declaring the enum writes no coder by hand.
- **The supported opt-in, not the default.** The scaffold default is the
  `duet canonical-sum` codegen verb, which annotates with the
  `CanonicalSumCodable` marker protocol and folds regeneration into
  `duet record`. Opting in here costs swift-syntax in the consumer's build
  graph — cold +62 %, warm ≈ +70 % on a seconds-fast test lane, as
  measured — which is why the macro lives in its own repository: a project
  that does not opt in never fetches it.
- Both vehicles assemble their output from one emission rule-set
  (`CanonicalSumEmission`, exported by `duet-tools` at an exact pin), and
  the lockstep expansion test pins the full expansion of the same
  worst-case enum the codegen vehicle pins. The byte dialect cannot fork
  between a generated file and a macro expansion without a red test in one
  of the two repositories.
- Dependencies: `duet-tools` at `exact: "0.13.0"` for the emission
  rule-set, and swift-syntax `600.0.0 ..< 700.0.0`. iOS 16 / macOS 13
  floors; swift-tools-version 6.0.

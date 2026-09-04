# duet-macros

`@CanonicalSum` — the macro vehicle of the Swift ceremony killer for
[Duet](https://github.com/modaal-agent/duet) repos: derives the canonical
`{"case": …}` Codable conformance for a sum type, as the framework's
serialization contract fixes it, so a feature declaring the enum writes no
coder by hand.

**This is the supported opt-in, not the default.** The default is the
`duet canonical-sum` codegen verb from
[duet-tools](https://github.com/modaal-agent/duet-tools) (annotation = the
`CanonicalSumCodable` marker protocol; regen folded into `duet record`). Opt in
here if you prefer Swift-native ergonomics and accept the measured build tax —
swift-syntax enters your build graph (as measured: cold +62 %, warm
≈ +70 % on a seconds-fast test lane).

> **Status: pre-release, current line 0.1.0.** One product, `CanonicalSum`,
> exporting the attached macro. This package pins `duet-tools` at an exact
> tag for the emission rule-set, so the bytes your expansions produce move
> only when this package's own version does; [CHANGELOG.md](CHANGELOG.md)
> states which `duet-tools` tag each release carries. Floors: iOS 16,
> macOS 13, swift-tools-version 6.0, swift-syntax `600.0.0 ..< 700.0.0`.

## Consuming

```swift
dependencies: [
  .package(url: "https://github.com/modaal-agent/duet-macros.git",
           .upToNextMinor(from: "0.1.0")),
],
targets: [
  .target(name: "Feature", dependencies: [
    .product(name: "CanonicalSum", package: "duet-macros"),
  ]),
]
```

```swift
import CanonicalSum

@CanonicalSum
enum Route: Equatable {
  case home
  case detail(String)
  case search(query: String?, scope: Int)
}
```

This is a `0.x` line: minor releases may break API, patch releases stay
source-compatible. Use `.upToNextMinor(from:)` rather than `from:` — SwiftPM
reads `from: "0.1.0"` as `0.1.0 ..< 1.0.0`, which would accept a breaking
`0.2.0` without asking.

## Why a separate repo

A macro dependency pins swift-syntax into every consumer graph. Keeping the
macro out of the `duet` library repo and out of `duet-tools` means projects
that did not opt in never fetch it — and SwiftPM resolves one URL package per
repository root anyway.

## The lockstep guarantee

Both vehicles assemble their output from ONE emission rule-set
(`CanonicalSumEmission`, exported by duet-tools), and the lockstep expansion
test here pins the full expansion of the same worst-case enum the codegen
vehicle's golden test pins in `duet-tools` — the byte dialect cannot fork
between a generated file and a macro expansion without a red test in one of
the two repositories.

## Layout and building

```
Package.swift                 the manifest at the repo root; duet-tools at an exact tag, swift-syntax
Sources/CanonicalSum/         the `@CanonicalSum` attribute declaration (the product an app links)
Sources/CanonicalSumMacros/   the compiler plugin: the expansion over CanonicalSumEmission
Tests/CanonicalSumTests/      the lockstep expansion tests
```

```sh
swift test   # the lockstep expansion tests; the gate before a tag
```

[CONTRIBUTING.md](CONTRIBUTING.md) states the rules every PR is reviewed
against and the release procedure.

## License

MIT — see [LICENSE](LICENSE).

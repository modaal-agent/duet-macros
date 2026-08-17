# duet-macros

`@CanonicalSum` — the macro vehicle of the Swift ceremony killer for
[Duet](https://github.com/modaal-agent/duet) repos: derives the canonical
`{"case": …}` Codable conformance for a sum type (serialization contract §4).

**This is the supported opt-in, not the default.** The scaffold default is the
`duet canonical-sum` codegen verb from
[duet-tools](https://github.com/modaal-agent/duet-tools) (annotation = the
`CanonicalSumCodable` marker protocol; regen folded into `duet record`). Opt in
here if you prefer Swift-native ergonomics and accept the measured build tax —
swift-syntax enters your build graph (as measured: cold +62 %, warm
≈ +70 % on a seconds-fast test lane).

## Why a separate repo

A macro dependency pins swift-syntax into every consumer graph. Keeping the
macro out of the `duet` library repo and out of `duet-tools` means projects
that did not opt in never fetch it — and SwiftPM resolves one URL package per
repository root anyway.

## The lockstep guarantee

Both vehicles assemble their output from ONE emission rule-set
(`CanonicalSumEmission`, exported by duet-tools), and the arms' lockstep gate
pins the same worst-case enum byte-for-byte in both repos' tests — the byte
dialect cannot fork between the codegen file and the macro expansion.

```swift
import CanonicalSum

@CanonicalSum
enum Route: Equatable {
  case home
  case detail(String)
  case search(query: String?, scope: Int)
}
```

## License

MIT — see [LICENSE](LICENSE).

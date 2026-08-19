# Contributing

- **Docs state the present rule, not the transition.** README sections and
  macro documentation are forward-looking: state what the macro does and the
  action the reader takes. Do not frame behavior as a replacement of past
  practice ("X replaces Y", "previously", "no longer") — the reader has no
  such past. Historical contrast belongs in commit messages, where the change
  itself is the subject.
- **Test doubles never live in a product's `Sources/`, `#if DEBUG`
  included.** A DEBUG gate keeps a double out of release binaries, not out of
  the module's API surface or its compile graph. A double one test target
  uses lives in that test target; a double shared across targets or with
  consumers ships in a dedicated test-support library product that only test
  targets link.
- **Licensing**: MIT, inbound = outbound; submitting a PR means your
  contribution is licensed under the [MIT License](LICENSE).

// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

/// Derives the canonical `{"case": …}` Codable conformance for a sum type
/// (serialization.md §4) — the macro OPT-IN vehicle of the Swift ceremony killer
/// (the scaffold default is the `duet canonical-sum` codegen verb with the
/// `CanonicalSumCodable` marker protocol). Payload rules: no payload → case
/// only; one unlabeled payload → inline envelope; labeled payloads → object
/// keyed by labels, nil fields omitted, all-optional payloads omit `value`
/// entirely. Emission is the shared rule-set (`CanonicalSumEmission`) — the two
/// vehicles cannot drift.
@attached(extension, conformances: Codable, names: arbitrary)
public macro CanonicalSum() =
  #externalMacro(module: "CanonicalSumMacros", type: "CanonicalSumMacro")

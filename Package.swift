// swift-tools-version:6.0

// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import CompilerPluginSupport
import PackageDescription

// The `@CanonicalSum` macro — the SUPPORTED OPT-IN vehicle of the Swift ceremony
// killer. The scaffold default is
// the `duet canonical-sum` codegen verb (annotation = the `CanonicalSumCodable`
// marker protocol); this macro exists for projects that prefer Swift-native
// ergonomics and accept the measured build tax (swift-syntax in the app's test
// lane — cold +62 %, warm ≈ +70 % as measured). Both vehicles
// assemble their output from ONE emission rule-set (`CanonicalSumEmission`, the
// duet-tools repo), so the byte dialect cannot fork; the lockstep expansion
// gate (Tests/) pins this vehicle's full expansion.
//
// Its OWN repo on purpose: a macro dependency pins swift-syntax into every
// consumer graph — that must never happen to projects that did not opt in, so
// neither the `duet` library repo nor `duet-tools` carries this product (and
// SwiftPM resolves one URL package per repository root anyway).
let package = Package(
  name: "duet-macros",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(name: "CanonicalSum", targets: ["CanonicalSum"])
  ],
  dependencies: [
    // The toolchain, pinned EXACTLY on the shared emission rule-set: the
    // lockstep gate below pins this vehicle's expansion against it, so the
    // pair moves in one deliberate re-pin commit.
    .package(url: "https://github.com/modaal-agent/duet-tools.git", exact: "0.13.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0"..<"700.0.0"),
  ],
  targets: [
    .macro(
      name: "CanonicalSumMacros",
      dependencies: [
        .product(name: "CanonicalSumEmission", package: "duet-tools"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "CanonicalSum",
      dependencies: ["CanonicalSumMacros"]
    ),
    .testTarget(
      name: "CanonicalSumTests",
      dependencies: [
        "CanonicalSumMacros",
        .product(name: "CanonicalSumEmission", package: "duet-tools"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)

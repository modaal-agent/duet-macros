// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import CanonicalSumMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

/// The macro half of the arms' lockstep gate: the full
/// expansion of the SAME worst-case enum the codegen vehicle pins
/// (tools/duet, CanonicalSumGenTests/GoldenTests) is pinned here as a literal —
/// BasicFormat's rendering of the shared rule-set (`CanonicalSumEmission`)
/// wrapped in this vehicle's extension shape (keys nested, `: Codable` on the
/// extension, no sentinel — expansion cannot be "missing", so SE-0295 has no
/// silent hole to defeat). The lockstep discipline: an emission-rule change must
/// update BOTH literals in the same commit; a drift in only one vehicle fails
/// only its own pin.
final class LockstepExpansionTests: XCTestCase {
  func testExpansionMatchesTheSharedRuleSet() {
    assertMacroExpansion(
      """
      @CanonicalSum
      enum WorstCaseRoute: Equatable {
        case home
        case detail(String)
        case peek(Int?)
        case search(query: String?, scope: Int)
        case badge(count: Int?)
        case filters(kind: String?, active: Bool?)
      }
      """,
      expandedSource: #"""
      enum WorstCaseRoute: Equatable {
        case home
        case detail(String)
        case peek(Int?)
        case search(query: String?, scope: Int)
        case badge(count: Int?)
        case filters(kind: String?, active: Bool?)
      }

      extension WorstCaseRoute: Codable {
        private enum SumCodingKeys: String, CodingKey {
          case caseName = "case"
          case value
        }

        private struct ValueKey: CodingKey {
          let stringValue: String
          var intValue: Int? {
              nil
          }
          init(_ key: String) {
              stringValue = key
          }
          init?(stringValue: String) {
              self.stringValue = stringValue
          }
          init?(intValue: Int) {
              nil
          }
        }

        public init(from decoder: Decoder) throws {
          let c = try decoder.container(keyedBy: SumCodingKeys.self)
          switch try c.decode(String.self, forKey: .caseName) {
          case "home":
              self = .home
          case "detail":
            self = .detail(try c.decode(String.self, forKey: .value))
          case "peek":
            self = .peek(try c.decodeIfPresent(Int.self, forKey: .value))
          case "search":
            let v = try c.nestedContainer(keyedBy: ValueKey.self, forKey: .value)
            self = .search(
              query: try v.decodeIfPresent(String.self, forKey: ValueKey("query")),
              scope: try v.decode(Int.self, forKey: ValueKey("scope")))
          case "badge":
            if c.contains(.value) {
              let v = try c.nestedContainer(keyedBy: ValueKey.self, forKey: .value)
              self = .badge(
                count: try v.decodeIfPresent(Int.self, forKey: ValueKey("count")))
            } else {
              self = .badge(count: nil)
            }
          case "filters":
            if c.contains(.value) {
              let v = try c.nestedContainer(keyedBy: ValueKey.self, forKey: .value)
              self = .filters(
                kind: try v.decodeIfPresent(String.self, forKey: ValueKey("kind")),
                active: try v.decodeIfPresent(Bool.self, forKey: ValueKey("active")))
            } else {
              self = .filters(kind: nil, active: nil)
            }
          case let unknown:
            throw DecodingError.dataCorruptedError(
              forKey: .caseName, in: c,
              debugDescription: "Unknown WorstCaseRoute case '\(unknown)'")
          }
        }

        public func encode(to encoder: Encoder) throws {
          var c = encoder.container(keyedBy: SumCodingKeys.self)
          switch self {
          case .home:
              try c.encode("home", forKey: .caseName)
          case let .detail(v0):
            try c.encode("detail", forKey: .caseName)
            try c.encode(v0, forKey: .value)
          case let .peek(v0):
            try c.encode("peek", forKey: .caseName)
            if let v0 {
                try c.encode(v0, forKey: .value)
            }
          case let .search(query, scope):
            try c.encode("search", forKey: .caseName)
            var v = c.nestedContainer(keyedBy: ValueKey.self, forKey: .value)
            try v.encodeIfPresent(query, forKey: ValueKey("query"))
            try v.encode(scope, forKey: ValueKey("scope"))
          case let .badge(count):
            try c.encode("badge", forKey: .caseName)
            if count != nil {
              var v = c.nestedContainer(keyedBy: ValueKey.self, forKey: .value)
              try v.encodeIfPresent(count, forKey: ValueKey("count"))
            }
          case let .filters(kind, active):
            try c.encode("filters", forKey: .caseName)
            if kind != nil || active != nil {
              var v = c.nestedContainer(keyedBy: ValueKey.self, forKey: .value)
              try v.encodeIfPresent(kind, forKey: ValueKey("kind"))
              try v.encodeIfPresent(active, forKey: ValueKey("active"))
            }
          }
        }
      }
      """#,
      macros: ["CanonicalSum": CanonicalSumMacro.self])
  }

  func testUnlabeledMultiPayloadIsDiagnosed() {
    assertMacroExpansion(
      """
      @CanonicalSum
      enum Bad: Equatable {
        case pair(String, Int)
      }
      """,
      expandedSource: """
        enum Bad: Equatable {
          case pair(String, Int)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message:
            "case 'pair': unlabeled payloads must be single — label the fields or wrap them in a struct",
          line: 1, column: 1)
      ],
      macros: ["CanonicalSum": CanonicalSumMacro.self])
  }
}

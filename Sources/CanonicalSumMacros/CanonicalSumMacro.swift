// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import CanonicalSumEmission
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// The macro vehicle of the Swift ceremony killer. Collection walks the attached
/// declaration's own syntax nodes; EMISSION is `CanonicalSumEmission` — the same
/// rule-set the `duet canonical-sum` codegen verb assembles from, so the two
/// vehicles cannot drift on the byte dialect. Helpers nest inside the generated
/// extension so nothing leaks at file scope.
public struct CanonicalSumMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      throw MacroError("@CanonicalSum can only attach to an enum")
    }
    var cases: [SumCase] = []
    for member in enumDecl.memberBlock.members {
      guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
      for element in caseDecl.elements {
        var fields: [SumCase.Field] = []
        for parameter in element.parameterClause?.parameters ?? [] {
          let rawLabel = parameter.firstName?.text
          let label = rawLabel == "_" ? nil : rawLabel
          let fieldType = parameter.type.trimmed.description
          fields.append(
            SumCase.Field(label: label, type: fieldType, optional: fieldType.hasSuffix("?")))
        }
        // Diagnose here (the emission rule-set preconditions the same invariant —
        // a thrown error beats a compiler-plugin crash for the author).
        if fields.count > 1, fields.contains(where: { $0.label == nil }) {
          throw MacroError(
            "case '\(element.name.text)': unlabeled payloads must be single — "
              + "label the fields or wrap them in a struct")
        }
        cases.append(SumCase(name: element.name.text, fields: fields))
      }
    }

    let enumName = type.trimmed.description
    var out: [String] = []
    out.append("extension \(enumName): Codable {")
    out.append(contentsOf: CanonicalSumEmission.codingKeyDecls(indent: "  "))
    out.append("")
    out.append(contentsOf: CanonicalSumEmission.initDecl(enumName: enumName, cases: cases))
    out.append("")
    out.append(contentsOf: CanonicalSumEmission.encodeDecl(cases: cases))
    out.append("}")
    return [try ExtensionDeclSyntax("\(raw: out.joined(separator: "\n"))")]
  }
}

struct MacroError: Error, CustomStringConvertible {
  let description: String

  init(_ description: String) {
    self.description = description
  }
}

@main
struct CanonicalSumPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [CanonicalSumMacro.self]
}

/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ComponentMacroError: Swift.Error, CustomStringConvertible {
    case notStructOrClass
    case mustBeFinalClass
    
    public var description: String {
        switch self {
        case .notStructOrClass:
            "@Component can only be attached to a struct or a class."
        case .mustBeFinalClass:
            "When using a class, a Component must be a final class."
        }
    }
}

public struct ECSComponentMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let isClass = declaration.as(ClassDeclSyntax.self) != nil
        guard let name = declaration.as(ClassDeclSyntax.self)?.name.trimmed ?? declaration.as(StructDeclSyntax.self)?.name.trimmed else {
            throw ComponentMacroError.notStructOrClass
        }
        
        if isClass {
            if declaration.modifiers.map({$0.trimmed.description}).contains(where: {$0 == "final"}) == false {
                throw ComponentMacroError.mustBeFinalClass
            }
        }
        
        var extensionDeclaration = "extension \(name)"
        if protocols.contains(where: {$0 == "GateEngine.Component"}) == false {
            extensionDeclaration += ": GateEngine.Component"
        }
        
        let access: String = declaration.modifiers.first(where: {
            let syntax = $0.trimmed.description
            if syntax == "public" || syntax == "open" || syntax == "package" {
                return true
            }
            return false
        })?.trimmedDescription ?? ""
        
        let extensionBody = "\(access) static let componentID: GateEngine.ComponentID = .init()"
        extensionDeclaration += "{\n" + extensionBody + "\n}"
        
        return [
            try ExtensionDeclSyntax(SyntaxNodeString(stringLiteral: extensionDeclaration))
        ]
    }
}

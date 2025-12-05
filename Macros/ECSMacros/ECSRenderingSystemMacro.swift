/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum RenderingSystemMacroError: Swift.Error, CustomStringConvertible {
    case notClass
    case invalidPhase
    
    public var description: String {
        switch self {
        case .notClass:
            "@RenderingSystem(phase) can only be attached to a class."
        case .invalidPhase:
            "The provided phase is not a valid RenderingSystem.Phase."
        }
    }
}

public struct ECSRenderingSystemMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw RenderingSystemMacroError.notClass
        }
        
        func getRenderingSystemPhase() throws -> TokenSyntax {
            switch node.arguments {
            case .argumentList(let labeledExprListSyntax):
                if let token = labeledExprListSyntax.lastToken(viewMode: .sourceAccurate) {
                    return "\(token.formatted())"
                }
            default:
                break
            }
            throw RenderingSystemMacroError.invalidPhase
        }
        
        let argument: String = try getRenderingSystemPhase().formatted().description
        
        var syntax = "override class var phase: RenderingSystem.Phase { .\(argument)}"
        
        if let access = classDecl.modifiers.first(where: {
            let syntax = $0.trimmed.description
            return syntax == "public" || syntax == "open" || syntax == "package"
        }) {
            syntax = access.trimmedDescription + " " + syntax
        }
        
        return [DeclSyntax(stringLiteral: syntax)]
    }
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard protocols.contains(where: {$0 == "GateEngine.RenderingSystem"}) == false else { return [] }
        
        guard let /*classDecl*/_ = declaration.as(ClassDeclSyntax.self) else {
            throw SystemMacroError.notClass
        }
        
//        let className = classDecl.name.trimmed

//        var protocols: [ExtensionDeclSyntax] = [try ProtocolDeclSyntax("GateEngine.RenderingSystem")] + protocols
//        return protocols
        return [
            try ExtensionDeclSyntax(SyntaxNodeString("GateEngine.RenderingSystem"))
        ]
    }
    
//    public static func expansion(
//        of node: SwiftSyntax.AttributeSyntax,
//        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
//        in context: some SwiftSyntaxMacros.MacroExpansionContext
//    ) throws -> [SwiftSyntax.DeclSyntax] {
//        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
//            throw SystemMacroError.notClass
//        }
//        let className = classDecl.name.trimmed
//        return [DeclSyntax(
//"""
//@_cdecl(\"eventHandler\")
//fileprivate func _eventHandler(pointer: UnsafeMutableRawPointer!, event: System.Event, arg: CUnsignedInt) -> CInt {
//    return \(className)._eventHandler(pointer: pointer, event: event, arg: arg)
//}
//"""
//        )]
//    }
}

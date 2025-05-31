/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum SystemMacroError: Error, CustomStringConvertible {
    case notClass
    
    public var description: String {
        switch self {
        case .notClass:
            "@System(phase) can only be attached to a class."
        }
    }
}

public struct ECSSystemMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw SystemMacroError.notClass
        }
        
        var syntax = "override class var phase: System.Phase { \(node.arguments!.formatted()) }"
        
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
        guard protocols.contains(where: {$0 == "GateEngine.System"}) == false else { return [] }
        
        guard let /*classDecl*/_ = declaration.as(ClassDeclSyntax.self) else {
            throw SystemMacroError.notClass
        }
        
//        let className = classDecl.name.trimmed

//        var protocols: [ExtensionDeclSyntax] = [try ProtocolDeclSyntax("GateEngine.System")] + protocols
//        return protocols
        return [
            try ExtensionDeclSyntax(SyntaxNodeString("GateEngine.System"))
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

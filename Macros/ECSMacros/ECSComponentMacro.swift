/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ComponentMacroError: Error, CustomStringConvertible {
    case notStructOrClass
    
    public var description: String {
        switch self {
        case .notStructOrClass:
            "@Component can only be attached to a struct or a class."
        }
    }
}

public struct ECSComponentMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let name = declaration.as(ClassDeclSyntax.self)?.name.trimmed ?? declaration.as(StructDeclSyntax.self)?.name.trimmed else {
            throw ComponentMacroError.notStructOrClass
        }
        
        var extensionDeclaration = "extension \(name)"
        if protocols.contains(where: {$0 == "GateEngine.Component"}) == false {
            extensionDeclaration += ": GateEngine.Component"
        }

        return [
            try ExtensionDeclSyntax(SyntaxNodeString(stringLiteral: extensionDeclaration)) {
                            """
                            public static let componentID: GateEngine.ComponentID = .init()
                            """
            }
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

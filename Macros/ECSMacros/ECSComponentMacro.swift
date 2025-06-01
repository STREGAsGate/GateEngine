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

public struct ECSComponentMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
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
        
//        let find = try InitializerDeclSyntax("init()") {
//            
//        }
        
//        if declaration.memberBlock.members.compactMap({InitializerDeclSyntax($0)}).isEmpty == true {
//            extensionBody = "\(access) init() { }" + "\n" + extensionBody
//        }
        
        extensionDeclaration += "{\n" + extensionBody + "\n}"
        
        return [
            try ExtensionDeclSyntax(SyntaxNodeString(stringLiteral: extensionDeclaration))
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

/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ECSMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        ECSSystemMacro.self,
        ECSComponentMacro.self
    ]
}

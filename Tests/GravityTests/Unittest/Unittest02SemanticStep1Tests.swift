/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

final class Unittest02SemanticStep1Tests: GravityXCTestCase {
    func testClass1Redeclared() async {
        await runGravity(at: "unittest/02-semantic_step1/class1_redeclared.gravity")
    }

    func testClass2InternalRedeclared() async {
        await runGravity(at: "unittest/02-semantic_step1/class2_internal_redeclared.gravity")
    }

    func testEnum1Redeclared() async {
        await runGravity(at: "unittest/02-semantic_step1/enum1_redeclared.gravity")
    }

    func testEnum2InternalRedeclared() async {
        await runGravity(at: "unittest/02-semantic_step1/enum2_internal_redeclared.gravity")
    }

    func testFunctionRedeclared() async {
        await runGravity(at: "unittest/02-semantic_step1/function_redeclared.gravity")
    }

    func testLocalVariablesNumber() async {
        await runGravity(at: "unittest/02-semantic_step1/local_variables_number.gravity")
    }

    func testVarRedeclared() async {
        await runGravity(at: "unittest/02-semantic_step1/var_redeclared.gravity")
    }
}

#endif

/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

final class Unittest01SyntaxTests: GravityXCTestCase {
    func testSyntaxClassDeclaration() async {
        await runGravity(at: "unittest/01-syntax/class_declaration.gravity")
    }

    func testEmptyEnum() async {
        // TODO: This test sometimes crashes the XCTest executable
        // await runGravity(at: "unittest/01-syntax/empty_enum.gravity")
    }

    func testEmptyReturn() async {
        await runGravity(at: "unittest/01-syntax/empty_return.gravity")
    }

    func testEmptyGravity() async {
        // TODO: This test sometimes crashes the XCTest executable
        // await runGravity(at: "unittest/01-syntax/empty.gravity")
    }

    func testFuncErrorParams() async {
        await runGravity(at: "unittest/01-syntax/func_error_params.gravity")
    }

    func testVar_in_if() async {
        await runGravity(at: "unittest/01-syntax/var_in_if.gravity")
    }

    func testVar_in_repeat() async {
        await runGravity(at: "unittest/01-syntax/var_in_repeat.gravity")
    }

    func testVar_in_switch() async {
        await runGravity(at: "unittest/01-syntax/var_in_switch.gravity")
    }

    func testVar_in_while() async {
        await runGravity(at: "unittest/01-syntax/var_in_while.gravity")
    }
}

#endif

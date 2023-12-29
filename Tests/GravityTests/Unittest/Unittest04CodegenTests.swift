/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

final class Unittest04CodegenTests: GravityXCTestCase {
    func testAssignment1() async {
        await runGravity(at: "unittest/04-codegen/assignment1.gravity")
    }

    func testAssignment2() async {
        await runGravity(at: "unittest/04-codegen/assignment2.gravity")
    }

    func testAssignment3() async {
        await runGravity(at: "unittest/04-codegen/assignment3.gravity")
    }

    func testAssignment4() async {
        await runGravity(at: "unittest/04-codegen/assignment4.gravity")
    }

    func testClass() async throws {
        await runGravity(at: "unittest/04-codegen/class/1.gravity")
        await runGravity(at: "unittest/04-codegen/class/2.gravity")
        await runGravity(at: "unittest/04-codegen/class/3.gravity")
        await runGravity(at: "unittest/04-codegen/class/4.gravity")
        await runGravity(at: "unittest/04-codegen/class/5.gravity")
        await runGravity(at: "unittest/04-codegen/class/6.gravity")
        await runGravity(at: "unittest/04-codegen/class/7.gravity")
        await runGravity(at: "unittest/04-codegen/class/8.gravity")
        await runGravity(at: "unittest/04-codegen/class/12.gravity")
        await runGravity(at: "unittest/04-codegen/class/13.gravity")
    }

    func testComplexExpression() async {
        await runGravity(at: "unittest/04-codegen/complex_expression.gravity")
    }

    func testFibonacci() async {
        await runGravity(at: "unittest/04-codegen/fibonacci.gravity")
    }

    func testFileAccess() async {
        await runGravity(at: "unittest/04-codegen/file_access.gravity")
    }

    func testKeywords() async throws {
        await runGravity(at: "unittest/04-codegen/keywords/_func.gravity")
    }

    func testListMap() async throws {
        await runGravity(at: "unittest/04-codegen/list_map/list1.gravity")
        await runGravity(at: "unittest/04-codegen/list_map/list2.gravity")
        await runGravity(at: "unittest/04-codegen/list_map/map1.gravity")
        await runGravity(at: "unittest/04-codegen/list_map/map2.gravity")
    }

    func testLiterals() async {
        await runGravity(at: "unittest/04-codegen/literals.gravity")
    }

    func testMultipleCall() async {
        await runGravity(at: "unittest/04-codegen/multiple_call.gravity")
    }

    func testVarDefault() async {
        await runGravity(at: "unittest/04-codegen/var_default.gravity")
    }
}

#endif

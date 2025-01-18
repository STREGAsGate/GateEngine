/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

final class Unittest03SemanticStep2Tests: GravityXCTestCase {
    func testClass1AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/class1_access_specifier.gravity")
    }

    func testClass2AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/class2_access_specifier.gravity")
    }

    func testEnum1AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/enum1_access_specifier.gravity")
    }

    func testEnum2AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/enum2_access_specifier.gravity")
    }

    func testFor1IdentifierNotFound() async {
        await runGravity(at: "unittest/03-semantic_step2/for1_identifier_not_found.gravity")
    }

    func testFunc1AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/func1_access_specifier.gravity")
    }

    func testFunc2AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/func2_access_specifier.gravity")
    }

    func testFunc3IdentifierRedeclared() async {
        await runGravity(at: "unittest/03-semantic_step2/func3_identifier_redeclared.gravity")
    }

    func testFunc4IdentifierRedeclared() async {
        await runGravity(at: "unittest/03-semantic_step2/func4_identifier_redeclared.gravity")
    }

    func testInvalidConditionIf() async {
        await runGravity(at: "unittest/03-semantic_step2/invalid_condition_if.gravity")
    }

    func testInvalidConditionWhile() async {
        await runGravity(at: "unittest/03-semantic_step2/invalid_condition_while.gravity")
    }

    func testOverrideProperty() async {
        await runGravity(at: "unittest/03-semantic_step2/override_property.gravity")
    }

    func testVar1AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/var1_access_specifier.gravity")
    }

    func testVar2AccessSpecifier() async {
        await runGravity(at: "unittest/03-semantic_step2/var2_access_specifier.gravity")
    }

    func testVarContainer() async {
        await runGravity(at: "unittest/03-semantic_step2/var_container.gravity")
    }
}

#endif

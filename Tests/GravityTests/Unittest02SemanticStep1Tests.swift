import XCTest
@testable import Gravity


final class Unittest02SemanticStep1Tests: XCTestCase {
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


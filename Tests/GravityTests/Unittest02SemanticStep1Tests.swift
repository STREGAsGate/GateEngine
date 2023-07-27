import XCTest
@testable import GravityC
@testable import Gravity


final class Unittest02SemanticStep1Tests: XCTestCase {
    func testClass1Redeclared() {
        let url = URL(resource: "unittest/02-semantic_step1/class1_redeclared.gravity")
        runGravity(at: url)
    }
    
    func testClass2InternalRedeclared() {
        let url = URL(resource: "unittest/02-semantic_step1/class2_internal_redeclared.gravity")
        runGravity(at: url)
    }
    
    func testEnum1Redeclared() {
        let url = URL(resource: "unittest/02-semantic_step1/enum1_redeclared.gravity")
        runGravity(at: url)
    }
    
    func testEnum2InternalRedeclared() {
        let url = URL(resource: "unittest/02-semantic_step1/enum2_internal_redeclared.gravity")
        runGravity(at: url)
    }
    
    func testFunctionRedeclared() {
        let url = URL(resource: "unittest/02-semantic_step1/function_redeclared.gravity")
        runGravity(at: url)
    }
    
    func testLocalVariablesNumber() {
        let url = URL(resource: "unittest/02-semantic_step1/local_variables_number.gravity")
        runGravity(at: url)
    }
    
    func testVarRedeclared() {
        let url = URL(resource: "unittest/02-semantic_step1/var_redeclared.gravity")
        runGravity(at: url)
    }
}


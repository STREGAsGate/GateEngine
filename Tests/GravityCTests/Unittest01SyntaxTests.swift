import XCTest
@testable import GravityC
@testable import Gravity


final class Unittest01SyntaxTests: XCTestCase {
    func testSyntaxClassDeclaration() {
        let url = URL(resource: "unittest/01-syntax/class_declaration.gravity")
        runGravity(at: url)
    }
    
    func testEmptyEnum() {
        let url = URL(resource: "unittest/01-syntax/empty_enum.gravity")
        runGravity(at: url)
    }
    
    func testEmptyReturn() {
        let url = URL(resource: "unittest/01-syntax/empty_return.gravity")
        runGravity(at: url)
    }
    
    func testEmptyGravity() {
        let url = URL(resource: "unittest/01-syntax/empty.gravity")
        runGravity(at: url)
    }
    
    func testFuncErrorParams() {
        let url = URL(resource: "unittest/01-syntax/func_error_params.gravity")
        runGravity(at: url)
    }
    
    func testVar_in_if() {
        let url = URL(resource: "unittest/01-syntax/var_in_if.gravity")
        runGravity(at: url)
    }
    
    func testVar_in_repeat() {
        let url = URL(resource: "unittest/01-syntax/var_in_repeat.gravity")
        runGravity(at: url)
    }
    
    func testVar_in_switch() {
        let url = URL(resource: "unittest/01-syntax/var_in_switch.gravity")
        runGravity(at: url)
    }
    
    func testVar_in_while() {
        let url = URL(resource: "unittest/01-syntax/var_in_while.gravity")
        runGravity(at: url)
    }
}


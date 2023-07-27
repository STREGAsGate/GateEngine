import XCTest
@testable import Gravity


final class Unittest01SyntaxTests: XCTestCase {
    override func setUp() async throws {
        try await Self.doSetUp()
    }
    
    
    func testSyntaxClassDeclaration() async {
        await runGravity(at: "unittest/01-syntax/class_declaration.gravity")
    }
    
    func testEmptyEnum() async {
        await runGravity(at: "unittest/01-syntax/empty_enum.gravity")
    }
    
    func testEmptyReturn() async {
        await runGravity(at: "unittest/01-syntax/empty_return.gravity")
    }
    
    func testEmptyGravity() async {
        await runGravity(at: "unittest/01-syntax/empty.gravity")
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


import XCTest
@testable import GravityC
@testable import Gravity


final class Unittest04CodegenTests: XCTestCase {
    func testAssignment1() {
        let url = URL(resource: "unittest/04-codegen/assignment1.gravity")
        runGravity(at: url)
    }
    
    func testAssignment2() {
        let url = URL(resource: "unittest/04-codegen/assignment2.gravity")
        runGravity(at: url)
    }
    
    func testAssignment3() {
        let url = URL(resource: "unittest/04-codegen/assignment3.gravity")
        runGravity(at: url)
    }
    
    func testAssignment4() {
        let url = URL(resource: "unittest/04-codegen/assignment4.gravity")
        runGravity(at: url)
    }
    
    func testClass() throws {
        let url = URL(resource: "unittest/04-codegen/class")
        let files = try Foundation.FileManager.default.contentsOfDirectory(atPath: url.path)
        for file in files {
            let url = url.appendingPathComponent(file)
            runGravity(at: url)
        }
    }
    
    func testComplexExpression() {
        let url = URL(resource: "unittest/04-codegen/complex_expression.gravity")
        runGravity(at: url)
    }
    
    func testFibonacci() {
        let url = URL(resource: "unittest/04-codegen/fibonacci.gravity")
        runGravity(at: url)
    }
    
    func testFileAccess() {
        let url = URL(resource: "unittest/04-codegen/file_access.gravity")
        runGravity(at: url)
    }
    
    func testKeywords() throws {
        let url = URL(resource: "unittest/04-codegen/keywords")
        let files = try Foundation.FileManager.default.contentsOfDirectory(atPath: url.path)
        for file in files {
            let url = url.appendingPathComponent(file)
            runGravity(at: url)
        }
    }
    
    func testListMap() throws {
        let url = URL(resource: "unittest/04-codegen/list_map")
        let files = try Foundation.FileManager.default.contentsOfDirectory(atPath: url.path)
        for file in files {
            let url = url.appendingPathComponent(file)
            runGravity(at: url)
        }
    }
    
    func testLiterals() {
        let url = URL(resource: "unittest/04-codegen/literals.gravity")
        runGravity(at: url)
    }
    
    func testMultipleCall() {
        let url = URL(resource: "unittest/04-codegen/multiple_call.gravity")
        runGravity(at: url)
    }
    
    func testVarDefault() {
        let url = URL(resource: "unittest/04-codegen/var_default.gravity")
        runGravity(at: url)
    }
}


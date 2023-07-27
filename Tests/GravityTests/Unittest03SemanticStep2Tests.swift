import XCTest
@testable import GravityC
@testable import Gravity

final class Unittest03SemanticStep2Tests: XCTestCase {
    func testClass1AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/class1_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testClass2AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/class2_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testEnum1AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/enum1_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testEnum2AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/enum2_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testFor1IdentifierNotFound() {
        let url = URL(resource: "unittest/03-semantic_step2/for1_identifier_not_found.gravity")
        runGravity(at: url)
    }
    
    func testFunc1AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/func1_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testFunc2AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/func2_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testFunc3IdentifierRedeclared() {
        let url = URL(resource: "unittest/03-semantic_step2/func3_identifier_redeclared.gravity")
        runGravity(at: url)
    }
    
    func testFunc4IdentifierRedeclared() {
        let url = URL(resource: "unittest/03-semantic_step2/func4_identifier_redeclared.gravity")
        runGravity(at: url)
    }
    
    func testInvalidConditionIf() {
        let url = URL(resource: "unittest/03-semantic_step2/invalid_condition_if.gravity")
        runGravity(at: url)
    }
    
    func testInvalidConditionWhile() {
        let url = URL(resource: "unittest/03-semantic_step2/invalid_condition_while.gravity")
        runGravity(at: url)
    }
    
    func testOverrideProperty() {
        let url = URL(resource: "unittest/03-semantic_step2/override_property.gravity")
        runGravity(at: url)
    }
    
    func testVar1AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/var1_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testVar2AccessSpecifier() {
        let url = URL(resource: "unittest/03-semantic_step2/var2_access_specifier.gravity")
        runGravity(at: url)
    }
    
    func testVarContainer() {
        let url = URL(resource: "unittest/03-semantic_step2/var_container.gravity")
        runGravity(at: url)
    }
}


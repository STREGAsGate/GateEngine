import XCTest
@testable import GravityC
@testable import Gravity


final class GravityExtendingTests: XCTestCase {
    var gravity: Gravity! = nil
    var randomValue: Int = 0
    override func setUp() {
        gravity = Gravity()
        randomValue = Int.random(in: -10000 ..< 10000)
    }
    
    func testHostGetClientVar() throws {
        try gravity.compile("var randomValue = \(randomValue); func main() {}")
        try gravity.runMain()
        let value = gravity.getVar("randomValue")!
        XCTAssertEqual(value.getInt(), randomValue)
    }
    
    func testHostSetClientVar() throws {
        gravity.setVar("randomValue", to: randomValue)
        try gravity.compile("extern var randomValue; func main() {}")
        try gravity.runMain()
        let value = gravity.getVar("randomValue")!
        XCTAssertEqual(value.getInt(), randomValue)
    }
    
    func testHostRunClientClosure() throws {
        let gValue = gravity.createValue(randomValue)
        try gravity.compile("func myFunction(randomValue) {return randomValue}; func main() {}")
        try gravity.runMain()
        let value = try gravity.runFunc("myFunction", withArguments: gValue)
        XCTAssertEqual(value.getInt(), randomValue)
    }
    
    func testClientRunHostClosure() throws {
        gravity.setFunc("myFunction") { gravity, args in
            return gravity.createValue(self.randomValue)
        }
        try gravity.compile("extern func myFunction() {}; func main() {return myFunction()}")
        let result = try gravity.runMain()
        XCTAssertEqual(result.getInt(), randomValue)
    }
    
    func testHostGetClientInstance() throws {
        try gravity.compile("class TheThing {}; var theThing = TheThing(); func main() {}")
        try gravity.runMain()
        let value = gravity.getInstance("theThing")!
        XCTAssertEqual(value.gravityClassName, "TheThing")
    }
    
    func testHostGetClientInstanceVar() throws {
        try gravity.compile("class TheThing {var myVar1; func myFunc(randomValue) { return randomValue}; var myVar2;}; var theThing = TheThing(); func main() {theThing.myVar2 = \(randomValue); theThing.myVar1 = 33}")
        try gravity.runMain()
        let instance = gravity.getInstance("theThing")!
        XCTAssertEqual(instance.getVar("myVar2"), randomValue)
        XCTAssertEqual(instance.getVar("myVar1"), 33)
    }
    
    func testHostRunClientInstanceClosure() throws {
        let gValue = gravity.createValue(randomValue)
        try gravity.compile("class TheThing {func myFunc(randomValue) {return randomValue}}; var theThing = TheThing(); func main() {}")
        try gravity.runMain()
        let value = try gravity.getInstance("theThing")!.runFunc("myFunc", withArguments: gValue)
        XCTAssertEqual(value.getInt(), randomValue)
    }
    
    func testHostCreateClientClass() throws {
        let theThingClass = gravity.createClass("TheThing")
        theThingClass.addVar("myVar")
        theThingClass.addFunc("myFunc") { gravity, sender, args in
            return "success!"
        }
        try gravity.compile("extern class TheThing; var theThing = TheThing(); func main() {}")
        try gravity.runMain()

        let instance = gravity.getInstance("theThing")!

        let gValue = gravity.createValue(randomValue)
        instance.setVar("myVar", to: gValue)

        XCTAssertEqual(instance.getVar("myVar"), randomValue)
        XCTAssertEqual(try instance.runFunc("myFunc"), "success!")
    }
}

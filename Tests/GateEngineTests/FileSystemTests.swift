import XCTest
@testable import GateEngine

final class FileSystemTests: XCTestCase {
    override func setUp() async throws {
        final class TestGameDelegate: GameDelegate {
            func didFinishLaunching(game: Game, options: LaunchOptions) {
                
            }
            func isHeadless() -> Bool {
                return true
            }
            nonisolated func gameIdentifier() -> StaticString? {
                return "com.STREGAsGate.GateEngine.tests"
            }
        }
        let delegate = await TestGameDelegate()
        Game.shared = await Game(delegate: delegate, currentPlatform: CurrentPlatform(delegate: delegate))
        await Game.shared.delegate.didFinishLaunching(game: Game.shared, options: [])
    }
    
    override func tearDown() async throws {
        await Game.shared.delegate.willTerminate(game: Game.shared)
    }
    
    func testDirectoryCreateExistsMoveDelete() async throws {
        let fileSystem = Game.shared.platform.fileSystem
        let path = try fileSystem.pathForSearchPath(.persistent, in: .currentUser) + "/test-NewFolder"
        var result = await fileSystem.itemExists(at: path)
        XCTAssertFalse(result)
        
        // Create
        try await fileSystem.createDirectory(at: path)
        result = await fileSystem.itemType(at: path) == .directory
        XCTAssertTrue(result)
        
        // Move + Exists
        let path2 = path + "2"
        try await fileSystem.moveItem(at: path, to: path2)
        result = await fileSystem.itemExists(at: path)
        XCTAssertFalse(result)
        result = await fileSystem.itemExists(at: path2)
        XCTAssertTrue(result)
        
        // Delete
        try await fileSystem.deleteItem(at: path2)
        result = await fileSystem.itemExists(at: path2)
        XCTAssertFalse(result)
    }
    
    func testFileWriteReadExistsMoveDelete() async throws {
        let fileSystem = Game.shared.platform.fileSystem
        let path = try fileSystem.pathForSearchPath(.persistent, in: .currentUser) + "/test-NewFile"
        var result = await fileSystem.itemExists(at: path)
        XCTAssertFalse(result)
        
        // Write + Read
        let writeData = "hollo world".data(using: .utf8)!
        try await fileSystem.write(writeData, to: path, options: [.createDirectories])
        var readData = try await fileSystem.read(from: path)
        XCTAssertEqual(writeData, readData)
        try await fileSystem.deleteItem(at: path)
        
        // Write atomically
        try await fileSystem.write(writeData, to: path, options: [.createDirectories, .atomically])
        readData = try await fileSystem.read(from: path)
        XCTAssertEqual(writeData, readData)
        
        // Move + Exists
        let path2 = path + "2"
        try await fileSystem.moveItem(at: path, to: path2)
        result = await fileSystem.itemExists(at: path)
        XCTAssertFalse(result)
        result = await fileSystem.itemExists(at: path2)
        XCTAssertTrue(result)
        
        // Delete
        try await fileSystem.deleteItem(at: path2)
        result = await fileSystem.itemExists(at: path2)
        XCTAssertFalse(result)
    }
    
    func testItemType() async throws {
        let fileSystem = Game.shared.platform.fileSystem
        let path = try fileSystem.pathForSearchPath(.persistent, in: .currentUser)
        
        let dirPath = path + "/test-HelloDir"
        try await fileSystem.createDirectory(at: dirPath)
        var result = await fileSystem.itemType(at: dirPath) == .directory
        XCTAssert(result)
        try await fileSystem.deleteItem(at: dirPath)

        let filePath = path + "/test-HelloFile"
        try await fileSystem.write("hollo world".data(using: .utf8)!, to: filePath)
        result = await fileSystem.itemType(at: filePath) == .file
        XCTAssert(result)
        try await fileSystem.deleteItem(at: filePath)
    }
}

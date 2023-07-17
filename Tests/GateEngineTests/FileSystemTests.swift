import XCTest
@testable import GateEngine

final class FileSystemTests: XCTestCase {
    override func setUp() async throws {
        final class TestGameDelegate: GameDelegate {
            func didFinishLaunching(game: Game, options: LaunchOptions) {
                
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
        XCTAssertFalse(fileSystem.itemExists(at: path))
        
        // Create
        try fileSystem.createDirectory(at: path)
        XCTAssertTrue(fileSystem.itemType(at: path) == .directory)
        
        // Move + Exists
        let path2 = path + "2"
        try await fileSystem.moveItem(at: path, to: path2)
        XCTAssertFalse(fileSystem.itemExists(at: path))
        XCTAssertTrue(fileSystem.itemExists(at: path2))
        
        // Delete
        try await fileSystem.deleteItem(at: path2)
        XCTAssertFalse(fileSystem.itemExists(at: path2))
    }
    
    func testFileWriteReadExistsMoveDelete() async throws {
        let fileSystem = Game.shared.platform.fileSystem
        let path = try fileSystem.pathForSearchPath(.persistent, in: .currentUser) + "/test-NewFile"
        XCTAssertFalse(fileSystem.itemExists(at: path))
        
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
        XCTAssertFalse(fileSystem.itemExists(at: path))
        XCTAssertTrue(fileSystem.itemExists(at: path2))
        
        // Delete
        try await fileSystem.deleteItem(at: path2)
        XCTAssertFalse(fileSystem.itemExists(at: path2))
    }
    
    func testItemType() async throws {
        let fileSystem = Game.shared.platform.fileSystem
        let path = try fileSystem.pathForSearchPath(.persistent, in: .currentUser)
        
        let dirPath = path + "/test-HelloDir"
        try fileSystem.createDirectory(at: dirPath)
        XCTAssert(fileSystem.itemType(at: dirPath) == .directory)
        try await fileSystem.deleteItem(at: dirPath)

        let filePath = path + "/test-HelloFile"
        try await fileSystem.write("hollo world".data(using: .utf8)!, to: filePath)
        XCTAssert(fileSystem.itemType(at: filePath) == .file)
        try await fileSystem.deleteItem(at: filePath)
    }
}

/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import XCTest
@testable import GateEngine

@MainActor
final class RawTextureTests: GateEngineXCTestCase {
    func testInt() {
        let expectedSize = Size2i(width: 16, height: 16)
        let rawTexture = RawTexture(imageSize: expectedSize)
        XCTAssertEqual(rawTexture.imageSize, expectedSize)
        XCTAssertEqual(rawTexture.count, expectedSize.width * expectedSize.height)
    }
    
    func testColorAtIndex() {
        let expectedSize = Size2i(width: 16, height: 16)
        var rawTexture = RawTexture(imageSize: expectedSize)
        let index = 24
        
        let color = Color(eightBitRed: 15, green: 30, blue: 45, alpha: 50)
        rawTexture.setColor(color, at: index)
        XCTAssertEqual(rawTexture.color(at: index), color)
    }
    
    func testPixelCoord() {
        let expectedSize = Size2i(width: 16, height: 16)
        let rawTexture = RawTexture(imageSize: expectedSize)
        var expectedIndex = 0
        for y in 0 ..< rawTexture.imageSize.height {
            for x in 0 ..< rawTexture.imageSize.width {
                let pixelCoord = Position2i(x: x, y: y)
                let index = rawTexture.index(for: pixelCoord)
                XCTAssertEqual(index, expectedIndex)
                expectedIndex += 1
            }
        }
    }
    
    func testTextureCoord() {
        let expectedSize = Size2i(width: 16, height: 16)
        let rawTexture = RawTexture(imageSize: expectedSize)
        let pixelSize: Size2f = Size2f.one / Size2f(expectedSize)
        let halfSize: Size2f = pixelSize / 2
        var expectedIndex = 0
        for y in 0 ..< rawTexture.imageSize.height {
            for x in 0 ..< rawTexture.imageSize.width {
                let pixelCoord = Position2i(x: x, y: y)
                let textureCoord: Position2f = Position2f(pixelSize * Position2f(pixelCoord)) + halfSize
                
                let index = rawTexture.index(for: textureCoord)
                XCTAssertEqual(index, expectedIndex)
                expectedIndex += 1
            }
        }
    }
    
    func testSwapAt() {
        let expectedSize = Size2i(width: 16, height: 16)
        var rawTexture = RawTexture(imageSize: expectedSize)
        
        let color1 = Color(eightBitRed: 15, green: 30, blue: 45, alpha: 50)
        rawTexture.setColor(color1, at: 24)
        
        let color2 = Color(eightBitRed: 16, green: 31, blue: 46, alpha: 51)
        rawTexture.setColor(color2, at: 55)
        
        rawTexture.swapAt(24, 55)
                
        XCTAssertEqual(rawTexture.color(at: 24), color2)
        XCTAssertEqual(rawTexture.color(at: 55), color1)
    }
}

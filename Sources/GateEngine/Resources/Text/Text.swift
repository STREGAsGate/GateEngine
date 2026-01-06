/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Text {
    public typealias SampleFilter = Material.Channel.SampleFilter
    
    public var color: Color
    private var _sampleFilter: SampleFilter? = nil
    public var sampleFilter: SampleFilter {
        get {
            return _sampleFilter ?? font.preferredSampleFilter
        }
        set {
            _sampleFilter = newValue
        }
    }

    private var _texture: Texture! = nil
    @MainActor @usableFromInline internal var texture: Texture {
        if needsUpdateTexture {
            needsUpdateTexture = false
            _texture = font.texture(forPointSize: UInt(actualPointSize.rounded()), style: style)
        }
        return _texture
    }
    @MainActor private var _geometry: MutableGeometry = MutableGeometry()
    @MainActor @usableFromInline internal var geometry: Geometry {
        if needsUpdateGeometry {
            needsUpdateGeometry = false
            updateGeometry()
        }
        return _geometry
    }
    private var _size: Size2 = .zero
    @MainActor public var size: Size2 {
        if needsUpdateGeometry, font.state == .ready {
            needsUpdateGeometry = false
            Task { @MainActor in
                self.updateGeometry()
            }
        }
        return _size / Float(interfaceScale)
    }

    @MainActor private func updateGeometry() {
        guard string.isEmpty == false else { return }
        let values = Self.rawGeometry(
            fromString: string,
            font: font,
            pointSize: actualPointSize,
            style: style,
            paragraphWidth: paragraphWidth,
            interfaceScale: interfaceScale
        )
        _geometry.rawGeometry = values.0
        _size = values.1
    }

    private var needsUpdateGeometry: Bool = true
    private var needsUpdateTexture: Bool = true

    public var string: String {
        didSet {
            if oldValue != string {
                self.needsUpdateGeometry = true
            }
        }
    }
    public var font: Font {
        didSet {
            if oldValue != font {
                self.needsUpdateGeometry = true
                self.needsUpdateTexture = true
            }
        }
    }
    @usableFromInline
    internal var interfaceScale: Float {
        didSet {
            if oldValue != interfaceScale {
                self.needsUpdateTexture = true
                self.needsUpdateGeometry = true
            }
        }
    }
    public var pointSize: UInt {
        didSet {
            if oldValue != pointSize {
                self.needsUpdateGeometry = true
                self.needsUpdateTexture = true
            }
        }
    }
    internal var actualPointSize: Float {
        return Float(pointSize) * interfaceScale
    }
    public var style: Font.Style {
        didSet {
            if oldValue != style {
                self.needsUpdateGeometry = true
                self.needsUpdateTexture = true
            }
        }
    }
    public var paragraphWidth: Float? {
        didSet {
            if oldValue != paragraphWidth {
                self.needsUpdateGeometry = true
            }
        }
    }

    @MainActor
    public init(
        string: String,
        font: Font = .default,
        pointSize: UInt,
        style: Font.Style = .regular,
        color: Color,
        paragraphWidth: Float? = nil,
        sampleFilter: SampleFilter? = nil
    ) {
        self.needsUpdateGeometry = true
        self.needsUpdateTexture = true
        self.color = color
        self.string = string
        self.font = font
        self.pointSize = pointSize
        self.style = style
        self.color = color
        self.paragraphWidth = paragraphWidth
        self._sampleFilter = sampleFilter
        #if RELEASE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))
        // Odds are good it's a retina display. Save some calls for rebuilding texture and geometry.
        self.interfaceScale = 2
        #else
        self.interfaceScale = 1
        #endif
        self._geometry = MutableGeometry(rawGeometry: nil)
    }

    @MainActor private static func rawGeometry(
        fromString string: String,
        font: Font,
        pointSize: Float,
        style: Font.Style,
        paragraphWidth: Float?,
        interfaceScale: Float
    ) -> (RawGeometry, Size2) {
        enum CharType {
            case space
            case tab
            case newLine
            case wordComponent
        }

        let roundedPointSize = UInt(pointSize.rounded())

        var rawGeometry: RawGeometry = []
        rawGeometry.reserveCapacity(string.count * 2)

        var lineCount = 1
        var xPosition: Float = 0
        var yPosition: Float = abs(obtainFirstLineYCoord())
        var width: Float = -.greatestFiniteMagnitude
        var heightMin: Float = .greatestFiniteMagnitude
        var heightMax: Float = -.greatestFiniteMagnitude

        var currentWord: [Triangle] = []
        currentWord.reserveCapacity(2)

        func newLine() {
            yPosition += pointSize
            lineCount += 1
        }

        func processWord() {
            rawGeometry.append(contentsOf: currentWord)
            currentWord.removeAll(keepingCapacity: true)
        }

        func moveCurrentWordToNextLine() {
            let pointSize = Float(pointSize)
            newLine()
            let offset: Float = .minimum(
                currentWord.first?.v1.position.x ?? 0,
                .minimum(currentWord.first?.v2.position.x ?? 0, currentWord.first?.v3.position.x ?? 0)
            )
            for index in currentWord.indices {
                currentWord[index].v1.position.x -= offset
                currentWord[index].v2.position.x -= offset
                currentWord[index].v3.position.x -= offset

                currentWord[index].v1.position.y += pointSize
                currentWord[index].v2.position.y += pointSize
                currentWord[index].v3.position.y += pointSize
            }
            xPosition -= offset
        }

        func charType(for character: Character) -> CharType {
            switch character {
            case " ":
                return .space
            case "\t":
                return .tab
            case "\n", "\r":
                return .newLine
            default:
                return .wordComponent
            }
        }

        func obtainFirstLineYCoord() -> Float {
            var yMin: Float = 0
            var xAdvance: Float = 0
            let yPosition: Float = 0
            func processCharacter(_ char: Character) {
                let quad = font.alignedCharacter(
                    forCharacter: char,
                    pointSize: roundedPointSize,
                    style: style,
                    origin: Position2(xPosition, yPosition),
                    xAdvance: &xAdvance
                )
                yMin = .minimum(yMin, quad.position.min.y)
            }

            for char in string {
                let charType: CharType = charType(for: char)
                if charType == .newLine {
                    return yMin
                } else if charType == .tab {
                    for _ in 0 ..< 4 {
                        processCharacter(" ")
                    }
                } else {
                    processCharacter(char)
                }

                if let paragraphWidth = paragraphWidth, xPosition > paragraphWidth {
                    return yMin
                }
            }
            return yMin
        }

        func insertCharacter(_ char: Character) {
            var xAdvance: Float = .nan
            let quad = font.alignedCharacter(
                forCharacter: char,
                pointSize: roundedPointSize,
                style: style,
                origin: Position2(xPosition, yPosition),
                xAdvance: &xAdvance
            )
            let v1 =
                Vertex(
                    px: quad.position.min.x,
                    py: quad.position.min.y,
                    pz: 0,
                    tu1: quad.texturePosition.min.x,
                    tv1: quad.texturePosition.min.y
                ) / interfaceScale
            let v2 =
                Vertex(
                    px: quad.position.max.x,
                    py: quad.position.min.y,
                    pz: 0,
                    tu1: quad.texturePosition.max.x,
                    tv1: quad.texturePosition.min.y
                ) / interfaceScale
            let v3 =
                Vertex(
                    px: quad.position.max.x,
                    py: quad.position.max.y,
                    pz: 0,
                    tu1: quad.texturePosition.max.x,
                    tv1: quad.texturePosition.max.y
                ) / interfaceScale
            let v4 =
                Vertex(
                    px: quad.position.min.x,
                    py: quad.position.max.y,
                    pz: 0,
                    tu1: quad.texturePosition.min.x,
                    tv1: quad.texturePosition.max.y
                ) / interfaceScale

            currentWord.append(Triangle(v1: v1, v2: v2, v3: v3, repairIfNeeded: false))
            currentWord.append(Triangle(v1: v3, v2: v4, v3: v1, repairIfNeeded: false))

            xPosition += xAdvance

            width = .maximum(width, xPosition)
            heightMin = .minimum(heightMin, quad.position.min.y)
            heightMax = .maximum(heightMax, quad.position.max.y)
        }

        for char in string {
            let charType: CharType = charType(for: char)

            if charType == .newLine {
                xPosition = 0
                newLine()
                continue
            } else if charType == .tab {
                for _ in 0 ..< 4 {
                    insertCharacter(" ")
                }
            } else {
                insertCharacter(char)
            }

            if let paragraphWidth = paragraphWidth, xPosition > paragraphWidth {
                if charType == .space {
                    currentWord.removeLast()
                    processWord()
                } else {
                    moveCurrentWordToNextLine()
                }
            } else if charType == .space {
                processWord()
            }
        }
        processWord()

        let height = heightMax - heightMin
        return (rawGeometry, Size2(width: width, height: height))
    }
}

public extension Text {
    @MainActor
    var isReady: Bool {
        return font.state == .ready && texture.state == .ready && geometry.state == .ready
    }
}

extension Text: Equatable {
    public static func == (lhs: Text, rhs: Text) -> Bool {
        return lhs.actualPointSize == rhs.actualPointSize
            && lhs.font == rhs.font
            && lhs.style == rhs.style
            && lhs.color == rhs.color
            && lhs.string == rhs.string
    }
}

extension Text: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
        hasher.combine(actualPointSize)
        hasher.combine(style)
        hasher.combine(color)
        hasher.combine(font)
    }
}

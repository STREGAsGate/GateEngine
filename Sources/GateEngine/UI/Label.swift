/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Label: View {
    public typealias SampleFilter = Material.Channel.SampleFilter
    public enum TextAlignment {
        case leading
        case centered
        case trailing
    }
    public var textAlignment: TextAlignment = .centered {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var textColor: Color
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
    @MainActor
    @usableFromInline
    internal var texture: Texture {
        if needsUpdateTexture {
            needsUpdateTexture = false
            _texture = font.texture(forPointSize: actualPointSize, style: style)
        }
        return _texture
    }
    
    public override func didChangeSuperview() {
        needsUpdateTexture = true
    }
    
    @MainActor
    private var _geometry: MutableGeometry = MutableGeometry(isText: true)
    @MainActor 
    @usableFromInline
    internal var geometry: Geometry {
        if needsUpdateGeometry {
            needsUpdateGeometry = false
            updateGeometry()
        }
        return _geometry
    }
    private var _size: Size2
    public var size: Size2 {
        if needsUpdateGeometry, font.state == .ready {
            needsUpdateGeometry = false
            self.updateGeometry()
        }
        return _size
    }
    
    public override func contentSize() -> Size2 {
        return size
    }

    @MainActor 
    private func updateGeometry() {
        self.setNeedsLayout()
        guard text.isEmpty == false else { return }
        let values = Self.rawGeometry(
            fromString: text,
            font: font,
            pointSize: actualPointSize,
            style: font.effectiveStyle(for: style),
            paragraphWidth: paragraphWidth
        )
        _geometry.rawGeometry = values.0
        _size = values.1 / interfaceScale
    }

    private var needsUpdateGeometry: Bool = true
    private var needsUpdateTexture: Bool = true

    public var text: String {
        didSet {
            if oldValue != text {
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
    
    public var fontSize: UInt {
        didSet {
            if oldValue != fontSize {
                self.needsUpdateGeometry = true
                self.needsUpdateTexture = true
            }
        }
    }
    internal var actualPointSize: UInt {
        return UInt((Float(fontSize) * interfaceScale).rounded(.awayFromZero))
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

    public init(
        text: String,
        font: Font = .default,
        fontSize: UInt,
        style: Font.Style = .regular,
        textColor: Color = .white,
        textAlignment: TextAlignment = .centered
    ) {
        self.needsUpdateGeometry = true
        self.needsUpdateTexture = true
        self.text = text
        self.font = font
        self.fontSize = fontSize
        self.style = style
        self.textColor = textColor
        self.textAlignment = textAlignment
        self._size = Size2(width: Float(fontSize), height: Float(fontSize))
        super.init()
    }
    
    override func shouldDraw() -> Bool {
        guard super.shouldDraw() else {return false}
        return font.state == .ready && texture.isReady && geometry.isReady
    }
    
    override func draw(_ rect: Rect, into canvas: inout UICanvas) {
        super.draw(rect, into: &canvas)
        
        let xOffset: Float
        let yOffset: Float
        switch textAlignment {
        case .leading:
            xOffset = self.marginInsets.leading * self.interfaceScale
        case .centered:
            xOffset = (rect.width / 2) - ((size.width / 2) * self.interfaceScale)
        case .trailing:
            xOffset = .maximum(0, rect.width - (size.width * self.interfaceScale) - (self.marginInsets.trailing * self.interfaceScale))
        }
        yOffset = (rect.height / 2) - ((size.height / 2) * self.interfaceScale)
        
        canvas.insert(
            DrawCommand(
                resource: .geometry(geometry),
                transforms: [Transform3(position: Position3(rect.x + xOffset, rect.y + yOffset, 0))],
                material: Material(texture: texture, sampleFilter: sampleFilter, tintColor: textColor),
                vsh: .standard,
                fsh: .textureSampleTintColor,
                flags: .userInterface
            )
        )
    }

    @MainActor 
    private static func rawGeometry(
        fromString string: String,
        font: Font,
        pointSize: UInt,
        style: Font.Style,
        paragraphWidth: Float?
    ) -> (RawGeometry, Size2) {
        enum CharType {
            case space
            case tab
            case newLine
            case wordComponent
        }

        var rawGeometry: RawGeometry = []
        rawGeometry.reserveCapacity(string.count * 2)

        var lineCount = 1
        var xPosition: Float = 0
        var yPosition: Float = abs(obtainFirstLineYCoord())
        var width: Float = -.greatestFiniteMagnitude
        var heightMin: Float = .greatestFiniteMagnitude
        var heightMax: Float = -.greatestFiniteMagnitude

        var currentWord: [Triangle] = []

        func newLine() {
            yPosition += Float(pointSize)
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
                    pointSize: pointSize,
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
                pointSize: pointSize,
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
                )
            let v2 =
                Vertex(
                    px: quad.position.max.x,
                    py: quad.position.min.y,
                    pz: 0,
                    tu1: quad.texturePosition.max.x,
                    tv1: quad.texturePosition.min.y
                )
            let v3 =
                Vertex(
                    px: quad.position.max.x,
                    py: quad.position.max.y,
                    pz: 0,
                    tu1: quad.texturePosition.max.x,
                    tv1: quad.texturePosition.max.y
                )
            let v4 =
                Vertex(
                    px: quad.position.min.x,
                    py: quad.position.max.y,
                    pz: 0,
                    tu1: quad.texturePosition.min.x,
                    tv1: quad.texturePosition.max.y
                )

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

extension Label: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(type(of: self))(text: \"\(text)\")"
    }
}

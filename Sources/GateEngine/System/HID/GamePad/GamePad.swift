/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum GamePadSymbolMap {
    case unknown

    case appleMFI

    case microsoftXbox

    /// The classic controller layouts are additive and include NES, SNES,  GameBoy, GameBoy Advance, DS, 3DS
    case nintendoClassic
    case nintendoGameCube
    case nintendoSwitch

    case sonyPlaystation
}

public struct GamePadSymbol: CustomStringConvertible {
    /// The mapping used to determine all other values
    public let map: GamePadSymbolMap
    internal let _id: GamePad.InternalID

    init(map: GamePadSymbolMap, id: GamePad.InternalID) {
        self.map = map
        self._id = id
    }

    public var id: Identifier {
        switch _id {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        default:
            break
        }

        switch map {
        case .nintendoClassic:
            fallthrough  //TODO: Add classic nintenod symbols
        case .nintendoGameCube:
            fallthrough  //TODO: Add GameCube nintenod symbols
        case .nintendoSwitch:
            switch _id {
            case .leftStick: return .L
            case .leftStickButton: return .LSB
            case .rightStick: return .R
            case .rightStickButton: return .RSB
            case .south: return .B
            case .east: return .A
            case .west: return .Y
            case .north: return .X
            case .leftShoulder: return .L
            case .leftTrigger: return .ZL
            case .rightShoulder: return .R
            case .rightTrigger: return .ZR
            case .menu1: return .plus
            case .menu2: return .minus
            case .menu3: return .home
            default: return .unknown
            }
        case .unknown, .microsoftXbox:
            switch _id {
            case .leftStick: return .L
            case .leftStickButton: return .LSB
            case .rightStick: return .R
            case .rightStickButton: return .RSB
            case .south: return .A
            case .east: return .B
            case .west: return .X
            case .north: return .Y
            case .leftShoulder: return .LB
            case .leftTrigger: return .LT
            case .rightShoulder: return .RB
            case .rightTrigger: return .RT
            case .menu1: return .guide
            case .menu2: return .back
            case .menu3: return .home
            default: return .unknown
            }
        case .appleMFI:
            switch _id {
            case .leftStick: return .L
            case .leftStickButton: return .L3
            case .rightStick: return .R
            case .rightStickButton: return .R3
            case .south: return .A
            case .east: return .B
            case .west: return .X
            case .north: return .Y
            case .leftShoulder: return .L1
            case .leftTrigger: return .L2
            case .rightShoulder: return .R1
            case .rightTrigger: return .R2
            case .menu1: return .menu
            case .menu2: return .options
            case .menu3: return .home
            default: return .unknown
            }
        case .sonyPlaystation:
            switch _id {
            case .leftStick: return .L
            case .leftStickButton: return .L3
            case .rightStick: return .R
            case .rightStickButton: return .R3
            case .south: return .cross
            case .east: return .circle
            case .west: return .square
            case .north: return .triangle
            case .leftShoulder: return .L1
            case .leftTrigger: return .L2
            case .rightShoulder: return .R1
            case .rightTrigger: return .R2
            case .menu1: return .options
            case .menu2: return .share
            case .menu3: return .playstation
            default: return .unknown
            }
        }
    }

    /**
     The color of the button on the physical controller.
     This value will be the actual collor on the controller if the color is known, otherwise this value will match `platformCollor`
     */
    public var color: Color { return platformColor }
    /// The color as determined by the platform holder. All triangles on a playstaion controller are green...
    public var platformColor: Color {
        switch map {
        case .unknown:
            return .monochrome
        case .appleMFI:
            switch id {
            case .A: return .red
            case .B: return .green
            case .X: return .yellow
            case .Y: return .blue
            default: return .monochrome
            }
        case .microsoftXbox:
            switch id {
            case .triangle: return .green
            case .cross: return .blue
            case .square: return .magenta
            case .circle: return .orange
            default: return .monochrome
            }
        case .nintendoClassic:
            switch id {
            case .A: return .red
            case .B: return .yellow
            case .X: return .blue
            case .Y: return .green
            default: return .monochrome
            }
        case .nintendoGameCube:
            switch id {
            case .A: return .green
            case .B: return .red
            case .X: return .blue
            case .Y: return .green
            default: return .monochrome
            }
        case .nintendoSwitch:
            return .monochrome
        case .sonyPlaystation:
            switch id {
            case .triangle: return .green
            case .cross: return .blue
            case .square: return .magenta
            case .circle: return .orange
            default: return .monochrome
            }
        }
    }

    public enum Identifier {
        case unknown

        case up
        case down
        case left
        case right

        case triangle
        case square
        case circle
        case cross
        case L1
        case L2
        case L3
        case R1
        case R2
        case R3
        case options
        case share
        case playstation

        case start
        case select
        case back
        case guide

        case A
        case B
        case X
        case Y

        case LB
        case LT
        case LSB
        case RB
        case RT
        case RSB

        case plus
        case minus
        case capture
        case home

        case L
        case ZL
        case R
        case ZR
        case Z

        case menu
    }

    public enum Color {
        case monochrome
        case red
        case green
        case blue
        case magenta
        case yellow
        case orange
    }

    /// A user facing string describing the input element.
    public var localizedName: String {
        // TODO: Determine if any controller manufacturer uses different names for any buttons in non-english locals
        switch self.id {
        case .unknown:
            return "[?]"
        case .up, .down, .left, .right, .start, .select, .back, .guide, .options, .share, .home,
            .capture, .plus, .minus, .triangle, .circle, .square, .cross:
            return "\(self.id)".capitalized
        case .playstation:
            return "PS"
        default:
            return "\(self.id)"
        }
    }

    public var description: String {
        return localizedName
    }
}

extension GamePad {
    public enum State {
        case connected
        case disconnected
    }

    public enum InternalID {
        case north
        case south
        case east
        case west
        case up
        case down
        case left
        case right
        case rightShoulder
        case leftShoulder
        case rightTrigger
        case leftTrigger
        case leftStickButton
        case rightStickButton
        case menu1
        case menu2
        case menu3
        case leftStick
        case rightStick
    }
}

@MainActor public final class GamePad {
    internal let interpreter: any GamePadInterpreter
    internal var identifier: Any? = nil

    public internal(set) var state: State = .connected

    public internal(set) var symbols: GamePadSymbolMap = .unknown {
        didSet {
            switch symbols {
            case .unknown, .appleMFI, .sonyPlaystation, .microsoftXbox:
                button.confirmButtonPath = \.south
                button.denyButtonPath = \.east
            case .nintendoClassic, .nintendoGameCube, .nintendoSwitch:
                button.confirmButtonPath = \.east
                button.denyButtonPath = \.south
            }
        }
    }

    internal init(interpreter: some GamePadInterpreter, identifier: Any?) {
        self.interpreter = interpreter
        self.identifier = identifier
        self.interpreter.setupGamePad(self)
    }

    internal func resetInputStates() {
        self.dpad.resetInputStates()
        self.button.resetInputStates()
        self.trigger.resetInputStates()
        self.shoulder.resetInputStates()
        self.stick.resetInputStates()
        self.menu.resetInputStates()
    }

    @MainActor @propertyWrapper public struct Polled<T> {
        weak var gamePad: GamePad? = nil
        var _wrappedValue: T
        public var wrappedValue: T {
            get {
                gamePad?.interpreter.hid.gamePads.pollIfNeeded()
                return _wrappedValue
            }
            set {
                _wrappedValue = newValue
            }
        }
        public init(wrappedValue: T) {
            _wrappedValue = wrappedValue
        }
        mutating func configureWith(gamePad: GamePad?) {
            self.gamePad = gamePad
        }
    }

    @MainActor @propertyWrapper public struct AnalogUpdatingPolled {
        weak var gamePad: GamePad? = nil
        weak var button: ButtonState? = nil

        var _wrappedValue: Float

        var neverAnalog = false
        var min: Float = .nan
        var max: Float = .nan
        var minHitCount: Int = 0
        var maxHitCount: Int = 0

        @MainActor public var wrappedValue: Float {
            get {
                gamePad?.interpreter.hid.gamePads.pollIfNeeded()
                return _wrappedValue
            }
            set {
                _wrappedValue = newValue
                guard self.button?.isAnalog == false else { return }
                guard self.neverAnalog == false else { return }

                let value = _wrappedValue
                if value > 0 && value < 1 {
                    // If there is an inbetween it is analog
                    button?.isAnalog = true
                } else {
                    let min = Swift.min(min, value)
                    if self.min != min {
                        minHitCount = 0
                        self.min = min
                    } else {
                        minHitCount += 1
                    }

                    let max = Swift.max(max, value)
                    if self.max != max {
                        maxHitCount = 0
                        self.max = max
                    } else {
                        maxHitCount += 1
                    }

                    if minHitCount >= 2 && maxHitCount >= 2 {
                        // if the input goes from min to max 2 times without an inbetween it is not analog
                        neverAnalog = true
                    }
                }
            }
        }
        public init(wrappedValue: Float) {
            _wrappedValue = wrappedValue
        }
        mutating func configureWith(gamePad: GamePad?, button: ButtonState) {
            self.gamePad = gamePad
            self.button = button
        }
    }

    @MainActor public class ButtonState {
        weak var gamePad: GamePad?
        let id: InternalID
        var currentReceipt: UInt8 = 0

        /// `true` if the button is considered down.
        @Polled public internal(set) var isPressed: Bool = false {
            didSet {
                if isPressed != oldValue {
                    currentReceipt &+= 1
                }
            }
        }

        // Returns a receipt for the current press or nil if not pressed
        public func isPressed(ifDifferent receipt: inout InputReceipts) -> Bool {
            guard self.isPressed else { return false }
            let key = ObjectIdentifier(self)
            if let receipt = receipt.values[key], receipt == currentReceipt {
                return false
            }
            receipt.values[key] = currentReceipt
            return true
        }

        /**

         - note: This function does **not** store `block` for later execution. If the function fails the block is discarded.
         */
        public func whenPressed(
            ifDifferent receipt: inout InputReceipts,
            run block: (ButtonState) -> Void
        ) {
            if isPressed(ifDifferent: &receipt) {
                block(self)
            }
        }

        /**
         Determines if this buttons `value` can have a value between 0 and 1
         This value will be initially false. The controller input has a few chances to report an analog value at which time this property will become true, otherwise it's assumed to always be digital.
         */
        public internal(set) var isAnalog: Bool = false

        /// The buttons pressed state 0 being not pressed and 1 being fully pressed
        @AnalogUpdatingPolled public internal(set) var value: Float = 0

        public internal(set) lazy var symbol: GamePadSymbol = GamePadSymbol(
            map: gamePad?.symbols ?? .unknown,
            id: id
        )

        internal func resetInputStates() {
            self.isPressed = false
            self.value = 0
        }

        init(gamePad: GamePad?, id: InternalID) {
            self.gamePad = gamePad
            self.id = id

            self._isPressed.configureWith(gamePad: gamePad)
            self._value.configureWith(gamePad: gamePad, button: self)
        }
    }

    @MainActor public class StickState {
        weak var gamePad: GamePad?
        let id: InternalID
        init(gamePad: GamePad?, id: InternalID) {
            self.gamePad = gamePad
            self.id = id

            self._xAxis.configureWith(gamePad: gamePad)
            self._yAxis.configureWith(gamePad: gamePad)
        }

        @Polled public internal(set) var xAxis: Float = 0
        @Polled public internal(set) var yAxis: Float = 0

        public func xAxisWithDeadzone(_ deadzone: Float = 0.1) -> Float {
            guard abs(xAxis) > deadzone else { return 0 }
            return xAxis
        }
        public func yAxisWithDeadzone(_ deadzone: Float = 0.1) -> Float {
            guard abs(yAxis) > deadzone else { return 0 }
            return yAxis
        }

        public func isWithinDeadzone(_ deadzone: Float = 0.1) -> Bool {
            return abs(xAxis) < deadzone && abs(yAxis) < deadzone
        }

        /// The vector2 angle of the sticks rotation
        public var direction: Direction2 {
            return Direction2(xAxis, yAxis).normalized
        }

        public private(set) lazy var button: ButtonState = ButtonState(
            gamePad: gamePad,
            id: id == .leftStickButton ? .leftStick : .rightStickButton
        )

        /// The stick is angled in a direction
        public var isPushed: Bool {
            return isWithinDeadzone(0.1) == false
        }

        /// The amount 0 ... 1 of the sticks pushed direction
        public var pushedAmount: Float {
            return .maximum(abs(xAxis), abs(yAxis))
        }

        internal func resetInputStates() {
            self.button.resetInputStates()
            self.xAxis = 0
            self.yAxis = 0
        }
    }

    @MainActor public class DPad {
        weak var gamePad: GamePad?
        init(gamePad: GamePad?) {
            self.gamePad = gamePad
        }

        public private(set) lazy var up: ButtonState = ButtonState(gamePad: gamePad, id: .up)
        public private(set) lazy var down: ButtonState = ButtonState(gamePad: gamePad, id: .down)
        public private(set) lazy var left: ButtonState = ButtonState(gamePad: gamePad, id: .left)
        public private(set) lazy var right: ButtonState = ButtonState(gamePad: gamePad, id: .right)

        public var isPressed: Bool {
            return up.isPressed || down.isPressed || left.isPressed || right.isPressed
        }

        internal func resetInputStates() {
            self.up.resetInputStates()
            self.down.resetInputStates()
            self.left.resetInputStates()
            self.right.resetInputStates()
        }
    }

    @MainActor public class Buttons {
        weak var gamePad: GamePad?
        init(gamePad: GamePad?) {
            self.gamePad = gamePad
        }

        public private(set) lazy var north: ButtonState = ButtonState(gamePad: gamePad, id: .north)
        public private(set) lazy var south: ButtonState = ButtonState(gamePad: gamePad, id: .south)
        public private(set) lazy var west: ButtonState = ButtonState(gamePad: gamePad, id: .west)
        public private(set) lazy var east: ButtonState = ButtonState(gamePad: gamePad, id: .east)

        internal var confirmButtonPath: KeyPath<GamePad.Buttons, GamePad.ButtonState> = \Self.south
        /// The button used to click menu items
        /// This button can be in a physically different place depending on controller symbols
        public var confirmButton: ButtonState {
            return self[keyPath: confirmButtonPath]
        }

        internal var denyButtonPath: KeyPath<GamePad.Buttons, GamePad.ButtonState> = \Self.east
        /// The button used to cancel or move back in a menu hierarchy
        /// This button can be in a physically different place depending on controller symbols
        public var denyButton: ButtonState {
            return self[keyPath: denyButtonPath]
        }

        public var isPressed: Bool {
            return north.isPressed || south.isPressed || west.isPressed || east.isPressed
        }

        internal func resetInputStates() {
            self.north.resetInputStates()
            self.south.resetInputStates()
            self.west.resetInputStates()
            self.east.resetInputStates()
        }
    }

    @MainActor public class Shoulders {
        weak var gamePad: GamePad?
        init(gamePad: GamePad?) {
            self.gamePad = gamePad
        }

        public private(set) lazy var left: ButtonState = ButtonState(
            gamePad: gamePad,
            id: .leftShoulder
        )
        public private(set) lazy var right: ButtonState = ButtonState(
            gamePad: gamePad,
            id: .rightShoulder
        )

        public var isPressed: Bool {
            return left.isPressed || right.isPressed
        }

        internal func resetInputStates() {
            self.left.resetInputStates()
            self.right.resetInputStates()
        }
    }

    @MainActor public class Triggers {
        weak var gamePad: GamePad?
        init(gamePad: GamePad?) {
            self.gamePad = gamePad
        }

        public private(set) lazy var left: ButtonState = ButtonState(
            gamePad: gamePad,
            id: .leftTrigger
        )
        public private(set) lazy var right: ButtonState = ButtonState(
            gamePad: gamePad,
            id: .rightTrigger
        )

        public var isPressed: Bool {
            return left.isPressed || right.isPressed
        }

        internal func resetInputStates() {
            self.left.resetInputStates()
            self.right.resetInputStates()
        }
    }

    @MainActor public class Sticks {
        weak var gamePad: GamePad?
        init(gamePad: GamePad?) {
            self.gamePad = gamePad
        }

        public private(set) lazy var left: StickState = StickState(gamePad: gamePad, id: .left)
        public private(set) lazy var right: StickState = StickState(gamePad: gamePad, id: .right)

        public var isPressed: Bool {
            return left.button.isPressed || right.button.isPressed
        }

        public var isPushed: Bool {
            return left.isPushed || right.isPushed
        }

        internal func resetInputStates() {
            self.left.resetInputStates()
            self.right.resetInputStates()
        }
    }

    @MainActor public class Menu {
        weak var gamePad: GamePad?
        init(gamePad: GamePad?) {
            self.gamePad = gamePad
        }

        public private(set) lazy var primary: ButtonState = ButtonState(
            gamePad: gamePad,
            id: .menu1
        )
        public private(set) lazy var secondary: ButtonState = ButtonState(
            gamePad: gamePad,
            id: .menu2
        )
        public private(set) lazy var tertiary: ButtonState = ButtonState(
            gamePad: gamePad,
            id: .menu3
        )

        public var isPressed: Bool {
            return primary.isPressed || secondary.isPressed || tertiary.isPressed
        }

        internal func resetInputStates() {
            self.primary.resetInputStates()
            self.secondary.resetInputStates()
            self.tertiary.resetInputStates()
        }
    }

    public private(set) lazy var dpad = DPad(gamePad: self)
    public private(set) lazy var button = Buttons(gamePad: self)
    public private(set) lazy var shoulder = Shoulders(gamePad: self)
    public private(set) lazy var trigger = Triggers(gamePad: self)
    public private(set) lazy var stick = Sticks(gamePad: self)
    public private(set) lazy var menu = Menu(gamePad: self)

    public var anyButtonIsPressed: Bool {
        return dpad.isPressed || button.isPressed || shoulder.isPressed || trigger.isPressed
            || stick.isPressed || menu.isPressed
    }

    public var anyStickIsPushed: Bool {
        return stick.isPushed
    }

    internal var hasInput: Bool {
        return anyButtonIsPressed || anyStickIsPushed
    }
}

#if canImport(GLFW)
import GLFW

@_transparent @usableFromInline public var GLFW_TRUE: Int32 {GLFW.GLFW_TRUE}
@_transparent @usableFromInline public var GLFW_FALSE: Int32 {GLFW.GLFW_FALSE}
@_transparent @usableFromInline public var GLFW_PRESS: Int32 {GLFW.GLFW_PRESS}
@_transparent @usableFromInline public var GLFW_KEY_ESCAPE: Int32 {GLFW.GLFW_KEY_ESCAPE}

@_transparent @usableFromInline public var GLFW_CONTEXT_VERSION_MAJOR: Int32 {GLFW.GLFW_CONTEXT_VERSION_MAJOR}
@_transparent @usableFromInline public var GLFW_CONTEXT_VERSION_MINOR: Int32 {GLFW.GLFW_CONTEXT_VERSION_MINOR}

@_transparent @usableFromInline public var GLFW_SAMPLES: Int32 {return GLFW.GLFW_SAMPLES}
@_transparent @usableFromInline public var GLFW_OPENGL_FORWARD_COMPAT: Int32 {return GLFW.GLFW_OPENGL_FORWARD_COMPAT}
@_transparent @usableFromInline public var GLFW_OPENGL_PROFILE: Int32 {return GLFW.GLFW_OPENGL_PROFILE}
@_transparent @usableFromInline public var GLFW_OPENGL_CORE_PROFILE: Int32 {return GLFW.GLFW_OPENGL_CORE_PROFILE}

func errorCallback(error: Int32, description: UnsafePointer<Int8>?) {
    guard let description = description else {return}
    let string = String(cString: description)
    print("GLFW Error: " + string)
}

@_transparent @usableFromInline public func glfwInit() {
    GLFW.glfwSetErrorCallback(errorCallback)
    if GLFW.glfwInit() != 1 {
        fatalError("Failed to initialize glfw.")
    }
}

@_transparent @usableFromInline public func glfwWindowHint(_ hint: Int32, _ value: Int32) {
    GLFW.glfwWindowHint(hint, value)
}

@_transparent @usableFromInline public func glfwTerminate() {
    GLFW.glfwTerminate()
}

@_transparent @usableFromInline public func glfwCreateWindow(_ width: Int32, _ height: Int32, _ title: String, _ monitor: OpaquePointer!, _ share: OpaquePointer!) -> OpaquePointer? {
    return GLFW.glfwCreateWindow(width, height, title, monitor, share)
}

@_transparent @usableFromInline public func glfwMakeContextCurrent(_ context: OpaquePointer!) {
    GLFW.glfwMakeContextCurrent(context)
}

@_transparent @usableFromInline public func glfwSwapInterval(_ interval: Int32) {
    GLFW.glfwSwapInterval(interval)
}

@_transparent @usableFromInline public func glfwWindowShouldClose(_ window: OpaquePointer!) -> Bool {
    return GLFW.glfwWindowShouldClose(window) == 1
}

@_transparent @usableFromInline public func glfwSetWindowShouldClose(_ window: OpaquePointer!, _ close: Bool) {
    GLFW.glfwSetWindowShouldClose(window, close ? 1 : 0)
}

@_transparent @usableFromInline public func glfwGetTime() -> TimeInterval {
    return GLFW.glfwGetTime()
}

@_transparent @usableFromInline public func glfwSwapBuffers(_ window: OpaquePointer!) {
    GLFW.glfwSwapBuffers(window)
}
 
@_transparent @usableFromInline public func glfwPollEvents() {
    GLFW.glfwPollEvents()
}

@_transparent @usableFromInline public func glfwDestroyWindow(_ window: OpaquePointer!) {
    GLFW.glfwDestroyWindow(window)
}

@_transparent @usableFromInline public func glfwGetWindowSize(_ window: OpaquePointer!) -> (width: Int32, height: Int32) {
    var width: Int32 = 0
    var height: Int32 = 0
    GLFW.glfwGetWindowSize(window, &width, &height)
    return (width, height)
}

@_transparent @usableFromInline public func glfwGetWindowFrameSize(_ window: OpaquePointer!) -> (top: Int32, left: Int32, bottom: Int32, right: Int32) {
    var top: Int32 = 0
    var left: Int32 = 0
    var bottom: Int32 = 0
    var right: Int32 = 0
    GLFW.glfwGetWindowFrameSize(window, &left, &top, &right, &bottom)
    return (top, left, bottom, right)
}

@_transparent @usableFromInline public func glfwGetWindowContentScale(_ window: OpaquePointer!) -> Float {
    var xscale: Float = 1
    GLFW.glfwGetWindowContentScale(window, &xscale, nil)
    return xscale
}

//MARK: Input

public let GLFW_JOYSTICK_LAST = GLFW.GLFW_JOYSTICK_LAST

public enum JoystickEvent {
    case connected
    case disconnected
    case unknown(Int32)
}
var joystickEventClosure: ((Int32, JoystickEvent)->())? = nil
func joystickEventCallback(joyStickID: Int32, event: Int32) {
    switch event {
    case GLFW_CONNECTED:
         joystickEventClosure?(joyStickID, .connected)
    case GLFW_DISCONNECTED:
        joystickEventClosure?(joyStickID, .disconnected)
    default:
        joystickEventClosure?(joyStickID, .unknown(event))
    }
}
@_transparent @usableFromInline public func glfwSetJoystickCallback(_ callback: ((_ joyStickID: Int32, _ event: JoystickEvent)->())?) {
    joystickEventClosure = callback
    if callback != nil {
        GLFW.glfwSetJoystickCallback(joystickEventCallback)
    }else{
        GLFW.glfwSetJoystickCallback(nil)
    }
}

@_transparent @usableFromInline public func glfwJoystickPresent(_ joyStickID: Int32) -> Bool {
    return GLFW.glfwJoystickPresent(joyStickID) == GLFW_TRUE
}

@_transparent @usableFromInline public func glfwJoystickIsGamepad(_ joyStickID: Int32) -> Bool {
    return GLFW.glfwJoystickIsGamepad(joyStickID) == GLFW_TRUE
}

@_transparent @usableFromInline public func glfwGetGamepadName(_ joyStickID: Int32) -> String? {
    guard let pointer = GLFW.glfwGetGamepadName(joyStickID) else {return nil}
    let data = Data(bytes: pointer, count: strlen(pointer))
    return String(data: data, encoding: .utf8)
}

public struct GamepadState {
    let buttons: [Bool]
    let axes: [Float]

    @_transparent @usableFromInline public var buttonStartPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_START)]}
    @_transparent @usableFromInline public var buttonBackPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_BACK)]}
    @_transparent @usableFromInline public var buttonGuidePressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_GUIDE)]}

    @_transparent @usableFromInline public var buttonNorthPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_TRIANGLE)]}
    @_transparent @usableFromInline public var buttonSouthPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_CROSS)]}
    @_transparent @usableFromInline public var buttonEastPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_CIRCLE)]}
    @_transparent @usableFromInline public var buttonWestPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_SQUARE)]}

    @_transparent @usableFromInline public var buttonLeftBumperPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_LEFT_BUMPER)]}
    @_transparent @usableFromInline public var buttonRighBumperPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER)]}

    @_transparent @usableFromInline public var buttonLeftStickPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_LEFT_THUMB)]}
    @_transparent @usableFromInline public var buttonRightStickPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_RIGHT_THUMB)]}

    @_transparent @usableFromInline public var buttonUpPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_DPAD_UP)]}
    @_transparent @usableFromInline public var buttonDownPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_DPAD_DOWN)]}
    @_transparent @usableFromInline public var buttonRightPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_DPAD_RIGHT)]}
    @_transparent @usableFromInline public var buttonLeftPressed: Bool {buttons[Int(GLFW_GAMEPAD_BUTTON_DPAD_LEFT)]}

    @_transparent @usableFromInline public var leftStickX: Float {axes[Int(GLFW_GAMEPAD_AXIS_LEFT_X)]}
    @_transparent @usableFromInline public var leftStickY: Float {axes[Int(GLFW_GAMEPAD_AXIS_LEFT_Y)]}
    @_transparent @usableFromInline public var rightStickX: Float {axes[Int(GLFW_GAMEPAD_AXIS_RIGHT_X)]}
    @_transparent @usableFromInline public var rightStickY: Float {axes[Int(GLFW_GAMEPAD_AXIS_RIGHT_Y)]}
    
    @_transparent @usableFromInline public var leftTrigger: Float {axes[Int(GLFW_GAMEPAD_AXIS_LEFT_TRIGGER)]}
    @_transparent @usableFromInline public var rightTrigger: Float {axes[Int(GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER)]}
}

@_transparent @usableFromInline public func glfwGetGamepadState(_ joyStickID: Int32) -> GamepadState? {
    var state: GLFWgamepadstate = GLFWgamepadstate()
    guard GLFW.glfwGetGamepadState(joyStickID, &state) == GLFW_TRUE else {return nil}
    return  GamepadState(buttons: [state.buttons.0 == GLFW_TRUE, 
                                       state.buttons.1 == GLFW_TRUE,
                                       state.buttons.2 == GLFW_TRUE,
                                       state.buttons.3 == GLFW_TRUE,
                                       state.buttons.4 == GLFW_TRUE, 
                                       state.buttons.5 == GLFW_TRUE, 
                                       state.buttons.6 == GLFW_TRUE, 
                                       state.buttons.7 == GLFW_TRUE, 
                                       state.buttons.8 == GLFW_TRUE, 
                                       state.buttons.9 == GLFW_TRUE, 
                                       state.buttons.10 == GLFW_TRUE, 
                                       state.buttons.11 == GLFW_TRUE, 
                                       state.buttons.12 == GLFW_TRUE, 
                                       state.buttons.13 == GLFW_TRUE, 
                                       state.buttons.14 == GLFW_TRUE],
                            axes: [state.axes.0, state.axes.1, state.axes.2, state.axes.3, state.axes.4, state.axes.5])
}

#endif

/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit) && canImport(UIKit) && !os(watchOS)
import GameController

internal class UIKitViewController: GCEventViewController {
    unowned let window: UIKitWindow
    init(window: UIKitWindow) {
        self.window = window
        super.init(nibName: nil, bundle: nil)
        self.loadViewIfNeeded()
    }

    override func loadView() {
        let size = window.uiWindow.bounds.size
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        self.view = GLKitView(viewController: self, size: size)
        #else
        if MetalRenderer.isSupported {
            self.view = MetalView(viewController: self, size: size)
        } else {
            #if canImport(GLKit)
            self.view = GLKitView(viewController: self, size: size)
            #endif
        }
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        #if os(iOS)
        if #available(iOS 13.4, *) {
            self.view.interactions.append(UIPointerInteraction(delegate: self))
        }
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
        #endif
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.window.updateStoredMetaData()
    }

    #if os(iOS)
    override var prefersHomeIndicatorAutoHidden: Bool {
        switch window.window.style {
        case .system:
            return false
        case .minimalSystemDecorations:
            return true
        }
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        switch window.window.style {
        case .system:
            return []
        case .minimalSystemDecorations:
            return .all
        }
    }
    #endif

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @inlinable
    private func type(for touch: UITouch) -> TouchKind {
        switch touch.type {
        case .direct:
            return .physical
        case .pencil, .stylus:
            return .stylus
        default:
            return .unknown
        }
    }

    @inlinable
    func locationOfTouch(_ touch: UITouch, from event: UIEvent?) -> (position: Position2, precision: Position2?) {
        let l = touch.location(in: nil)
        let p = touch.preciseLocation(in: nil)
        return (Position2(Float(p.x), Float(p.y)), p != l ? Position2(Float(p.x), Float(p.y)) : nil)
    }
    
    @inlinable
    func precisionLocationOfTouch(_ touch: UITouch, from event: UIEvent?) -> Position2? {
        let p = touch.preciseLocation(in: nil)
        return Position2(Float(p.x), Float(p.y))
    }

    #if !os(tvOS)
    @inlinable
    func deltaLocationOfTouch(_ touch: UITouch, from event: UIEvent?) -> Position2 {
        let cgL = touch.preciseLocation(in: nil)
        let cgPL = touch.precisePreviousLocation(in: nil)
        return Position2(Float(cgPL.x - cgL.x), Float(cgPL.y - cgL.y))
    }

    @available(iOS 13.4, *)
    @inlinable
    func mouseButtonFromEvent(_ event: UIEvent?) -> MouseButton {
        guard let event else { return .unknown(nil) }
        switch event.buttonMask {
        case .button(1):
            return .button1
        case .button(2):
            return .button2
        case .button(3):
            return .button3
        case .button(4):
            return .button4
        case .button(5):
            return .button5
        default:
            // TODO: Figure out the button number
            return .unknown(nil)
        }
    }
    #endif

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        for touch in touches {
            let location = locationOfTouch(touch, from: event)
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                if let event = event {
                    Game.shared.hid.mouseClick(
                        event: .buttonDown,
                        button: mouseButtonFromEvent(event),
                        position: location.position,
                        delta: self.deltaLocationOfTouch(touch, from: event),
                        window: self.window.window
                    )
                }
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                Game.shared.hid.screenTouchChange(
                    id: id,
                    kind: type(for: touch),
                    event: .began,
                    position: location.position,
                    precisionPosition: location.precision,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            case .indirect:
                Game.shared.hid.surfaceTouchChange(
                    id: id,
                    event: .began,
                    surfaceID: ObjectIdentifier(UIDevice.current),
                    normalizedPosition: location.position,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            default:
                break
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        for touch in touches {
            let location = locationOfTouch(touch, from: event)
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                let deltaPosition = deltaLocationOfTouch(touch, from: event)
                Game.shared.hid.mouseChange(
                    event: .moved,
                    position: location.position,
                    delta: deltaPosition,
                    window: self.window.window
                )
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                Game.shared.hid.screenTouchChange(
                    id: id,
                    kind: type(for: touch),
                    event: .moved,
                    position: location.position,
                    precisionPosition: location.precision,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            case .indirect:
                Game.shared.hid.surfaceTouchChange(
                    id: id,
                    event: .moved,
                    surfaceID: ObjectIdentifier(UIDevice.current),
                    normalizedPosition: location.position,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            default:
                break
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        for touch in touches {
            let location = locationOfTouch(touch, from: event)
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                Game.shared.hid.mouseClick(
                    event: .buttonUp,
                    button: mouseButtonFromEvent(event),
                    position: location.position,
                    delta: self.deltaLocationOfTouch(touch, from: event),
                    window: self.window.window
                )
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                Game.shared.hid.screenTouchChange(
                    id: id,
                    kind: type(for: touch),
                    event: .ended,
                    position: location.position,
                    precisionPosition: location.precision,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            case .indirect:
                Game.shared.hid.surfaceTouchChange(
                    id: id,
                    event: .ended,
                    surfaceID: ObjectIdentifier(UIDevice.current),
                    normalizedPosition: location.position,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            default:
                break
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        for touch in touches {
            let location = locationOfTouch(touch, from: event)
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                Game.shared.hid.mouseClick(
                    event: .buttonUp,
                    button: mouseButtonFromEvent(event),
                    position: location.position,
                    delta: self.deltaLocationOfTouch(touch, from: event),
                    window: self.window.window
                )
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                Game.shared.hid.screenTouchChange(
                    id: id,
                    kind: type(for: touch),
                    event: .canceled,
                    position: location.position,
                    precisionPosition: location.precision,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            case .indirect:
                Game.shared.hid.surfaceTouchChange(
                    id: id,
                    event: .canceled,
                    surfaceID: ObjectIdentifier(UIDevice.current),
                    normalizedPosition: location.position,
                    pressure: Float(touch.force / touch.maximumPossibleForce),
                    window: self.window.window
                )
            default:
                break
            }
        }
    }

    // MARK: - Keyboard
    @inlinable
    func keysFromEvent(_ event: UIPressesEvent) -> [(key: KeyboardKey, characters: String?)] {
        var keys: [(key: KeyboardKey, characters: String?)] = []
        for press in event.allPresses {
            guard let pressKey = press.key else { continue }

            var key: GateEngine.KeyboardKey? = nil

            #if GATEENGINE_DEBUG_HID
            var keyName: String? = nil
            #endif

            switch pressKey.keyCode {
            #if GATEENGINE_DEBUG_HID
            case .keyboardErrorRollOver: /* ErrorRollOver */
                keyName = "keyboardErrorRollOver"
            case .keyboardPOSTFail: /* POSTFail */
                keyName = "keyboardPOSTFail"
            case .keyboardErrorUndefined: /* ErrorUndefined */
                keyName = "keyboardErrorUndefined"
            #endif

            case .keyboardA: /* a or A */
                key = .character("a", .standard)
            case .keyboardB: /* b or B */
                key = .character("b", .standard)
            case .keyboardC: /* c or C */
                key = .character("c", .standard)
            case .keyboardD: /* d or D */
                key = .character("d", .standard)
            case .keyboardE: /* e or E */
                key = .character("e", .standard)
            case .keyboardF: /* f or F */
                key = .character("f", .standard)
            case .keyboardG: /* g or G */
                key = .character("g", .standard)
            case .keyboardH: /* h or H */
                key = .character("h", .standard)
            case .keyboardI: /* i or I */
                key = .character("i", .standard)
            case .keyboardJ: /* j or J */
                key = .character("j", .standard)
            case .keyboardK: /* k or K */
                key = .character("k", .standard)
            case .keyboardL: /* l or L */
                key = .character("l", .standard)
            case .keyboardM: /* m or M */
                key = .character("m", .standard)
            case .keyboardN: /* n or N */
                key = .character("n", .standard)
            case .keyboardO: /* o or O */
                key = .character("o", .standard)
            case .keyboardP: /* p or P */
                key = .character("p", .standard)
            case .keyboardQ: /* q or Q */
                key = .character("q", .standard)
            case .keyboardR: /* r or R */
                key = .character("r", .standard)
            case .keyboardS: /* s or S */
                key = .character("s", .standard)
            case .keyboardT: /* t or T */
                key = .character("t", .standard)
            case .keyboardU: /* u or U */
                key = .character("u", .standard)
            case .keyboardV: /* v or V */
                key = .character("v", .standard)
            case .keyboardW: /* w or W */
                key = .character("w", .standard)
            case .keyboardX: /* x or X */
                key = .character("x", .standard)
            case .keyboardY: /* y or Y */
                key = .character("y", .standard)
            case .keyboardZ: /* z or Z */
                key = .character("z", .standard)
            case .keyboard1: /* 1 or ! */
                key = .character("1", .standard)
            case .keyboard2: /* 2 or @ */
                key = .character("2", .standard)
            case .keyboard3: /* 3 or # */
                key = .character("3", .standard)
            case .keyboard4: /* 4 or $ */
                key = .character("4", .standard)
            case .keyboard5: /* 5 or % */
                key = .character("5", .standard)
            case .keyboard6: /* 6 or ^ */
                key = .character("6", .standard)
            case .keyboard7: /* 7 or & */
                key = .character("7", .standard)
            case .keyboard8: /* 8 or * */
                key = .character("8", .standard)
            case .keyboard9: /* 9 or ( */
                key = .character("9", .standard)
            case .keyboard0: /* 0 or ) */
                key = .character("0", .standard)

            case .keyboardReturnOrEnter: /* Return (Enter) */
                key = .enter(.standard)
            case .keyboardEscape: /* Escape */
                key = .escape
            case .keyboardDeleteOrBackspace: /* Delete (Backspace) */
                key = .backspace
            case .keyboardTab: /* Tab */
                key = .tab
            case .keyboardSpacebar: /* Spacebar */
                key = .space
            case .keyboardHyphen: /* - or _ */
                key = .character("-", .standard)
            case .keyboardEqualSign: /* = or + */
                key = .character("=", .standard)
            case .keyboardOpenBracket: /* [ or { */
                key = .character("[", .standard)
            case .keyboardCloseBracket: /* ] or } */
                key = .character("]", .standard)
            case .keyboardBackslash: /* \ or | */
                key = .character("\\", .standard)
            case .keyboardNonUSPound: /* Non-US # or _ */
                key = .character("\\", .standard)
            /* Typical language mappings: US: \| Belg: μ`£ FrCa: <}> Dan:’* Dutch: <> Fren:*μ
                                          Ger: #’ Ital: ù§ LatAm: }`] Nor:,* Span: }Ç Swed: ,*
                                          Swiss: $£ UK: #~. */
            case .keyboardSemicolon: /* ; or : */
                key = .character(";", .standard)
            case .keyboardQuote: /* ' or " */
                key = .character("'", .standard)
            case .keyboardGraveAccentAndTilde: /* Grave Accent and Tilde */
                key = .character("`", .standard)
            case .keyboardComma: /* , or < */
                key = .character(",", .standard)
            case .keyboardPeriod: /* . or > */
                key = .character(".", .standard)
            case .keyboardSlash: /* / or ? */
                key = .character("/", .standard)
            case .keyboardCapsLock: /* Caps Lock */
                key = .capsLock

            /* Function keys */
            case .keyboardF1: /* F1 */
                key = .function(1)
            case .keyboardF2: /* F2 */
                key = .function(2)
            case .keyboardF3: /* F3 */
                key = .function(3)
            case .keyboardF4: /* F4 */
                key = .function(4)
            case .keyboardF5: /* F5 */
                key = .function(5)
            case .keyboardF6: /* F6 */
                key = .function(6)
            case .keyboardF7: /* F7 */
                key = .function(7)
            case .keyboardF8: /* F8 */
                key = .function(8)
            case .keyboardF9: /* F9 */
                key = .function(9)
            case .keyboardF10: /* F10 */
                key = .function(10)
            case .keyboardF11: /* F11 */
                key = .function(11)
            case .keyboardF12: /* F12 */
                key = .function(12)
            case .keyboardPrintScreen: /* Print Screen */
                key = .printScreen
            case .keyboardScrollLock: /* Scroll Lock */
                key = .scrollLock
            case .keyboardPause: /* Pause */
                key = .pauseBreak
            case .keyboardInsert: /* Insert */
                key = .insert
            case .keyboardHome: /* Home */
                key = .home
            case .keyboardPageUp: /* Page Up */
                key = .pageUp
            case .keyboardDeleteForward: /* Delete Forward */
                key = .delete
            case .keyboardEnd: /* End */
                key = .end
            case .keyboardPageDown: /* Page Down */
                key = .pageDown
            case .keyboardRightArrow: /* Right Arrow */
                key = .right
            case .keyboardLeftArrow: /* Left Arrow */
                key = .left
            case .keyboardDownArrow: /* Down Arrow */
                key = .down
            case .keyboardUpArrow: /* Up Arrow */
                key = .up

            /* Keypad (numpad) keys */
            case .keypadNumLock: /* Keypad NumLock or Clear */
                key = .numLock
            case .keypadSlash: /* Keypad / */
                key = .character("/", .numberPad)
            case .keypadAsterisk: /* Keypad * */
                key = .character("*", .numberPad)
            case .keypadHyphen: /* Keypad - */
                key = .character("-", .numberPad)
            case .keypadPlus: /* Keypad + */
                key = .character("+", .numberPad)
            case .keypadEnter: /* Keypad Enter */
                key = .enter(.numberPad)
            case .keypad1: /* Keypad 1 or End */
                key = .character("1", .numberPad)
            case .keypad2: /* Keypad 2 or Down Arrow */
                key = .character("2", .numberPad)
            case .keypad3: /* Keypad 3 or Page Down */
                key = .character("3", .numberPad)
            case .keypad4: /* Keypad 4 or Left Arrow */
                key = .character("4", .numberPad)
            case .keypad5: /* Keypad 5 */
                key = .character("5", .numberPad)
            case .keypad6: /* Keypad 6 or Right Arrow */
                key = .character("6", .numberPad)
            case .keypad7: /* Keypad 7 or Home */
                key = .character("7", .numberPad)
            case .keypad8: /* Keypad 8 or Up Arrow */
                key = .character("8", .numberPad)
            case .keypad9: /* Keypad 9 or Page Up */
                key = .character("9", .numberPad)
            case .keypad0: /* Keypad 0 or Insert */
                key = .character("0", .numberPad)
            case .keypadPeriod: /* Keypad . or Delete */
                key = .character(".", .numberPad)
            case .keyboardNonUSBackslash: /* Non-US \ or | */
                key = .character("\\", .standard)
            /* On Apple ISO keyboards, this is the section symbol (§/±) */
            /* Typical language mappings: Belg:<\> FrCa:«°» Dan:<\> Dutch:]|[ Fren:<> Ger:<|>
                                          Ital:<> LatAm:<> Nor:<> Span:<> Swed:<|> Swiss:<\>
                                          UK:\| Brazil: \|. */
            case .keyboardApplication: /* Application */
                key = .contextMenu
            #if GATEENGINE_DEBUG_HID
            case .keyboardPower: /* Power */
                keyName = "keyboardPower"
            #endif
            case .keypadEqualSign: /* Keypad = */
                key = .character("=", .numberPad)

            /* Additional keys */
            case .keyboardF13: /* F13 */
                key = .function(13)
            case .keyboardF14: /* F14 */
                key = .function(14)
            case .keyboardF15: /* F15 */
                key = .function(15)
            case .keyboardF16: /* F16 */
                key = .function(16)
            case .keyboardF17: /* F17 */
                key = .function(17)
            case .keyboardF18: /* F18 */
                key = .function(18)
            case .keyboardF19: /* F19 */
                key = .function(19)
            case .keyboardF20: /* F20 */
                key = .function(20)
            case .keyboardF21: /* F21 */
                key = .function(21)
            case .keyboardF22: /* F22 */
                key = .function(22)
            case .keyboardF23: /* F23 */
                key = .function(23)
            case .keyboardF24: /* F24 */
                key = .function(24)
            #if GATEENGINE_DEBUG_HID
            case .keyboardExecute: /* Execute */
                keyName = "keyboardExecute"
            #endif
            case .keyboardHelp: /* Help */
                key = .insert
            #if GATEENGINE_DEBUG_HID
            case .keyboardMenu: /* Menu */
                keyName = "keyboardMenu"
            case .keyboardSelect: /* Select */
                keyName = "keyboardSelect"
            case .keyboardStop: /* Stop */
                keyName = "keyboardStop"
            case .keyboardAgain: /* Again */
                keyName = "keyboardAgain"
            case .keyboardUndo: /* Undo */
                keyName = "keyboardUndo"
            case .keyboardCut: /* Cut */
                keyName = "keyboardCut"
            case .keyboardCopy: /* Copy */
                keyName = "keyboardCopy"
            case .keyboardPaste: /* Paste */
                keyName = "keyboardPaste"
            case .keyboardFind: /* Find */
                keyName = "keyboardFind"
            #endif
            case .keyboardMute: /* Mute */
                key = .mute
            case .keyboardVolumeUp: /* Volume Up */
                key = .volumeUp
            case .keyboardVolumeDown: /* Volume Down */
                key = .volumeDown

            #if GATEENGINE_DEBUG_HID
            case .keyboardLockingCapsLock: /* Locking Caps Lock */
                keyName = "keyboardLockingCapsLock"
            case .keyboardLockingNumLock: /* Locking Num Lock */
                keyName = "keyboardLockingNumLock"
            /* Implemented as a locking key; sent as a toggle button. Available for legacy support;
               however, most systems should use the non-locking version of this key. */
            case .keyboardLockingScrollLock: /* Locking Scroll Lock */
                keyName = "keyboardLockingScrollLock"
            #endif
            case .keypadComma: /* Keypad Comma */
                key = .character(",", .numberPad)
            case .keypadEqualSignAS400: /* Keypad Equal Sign for AS/400 */
                key = .character("=", .numberPad)

            /* See the footnotes in the USB specification for what keys these are commonly mapped to.
             * https://www.usb.org/sites/default/files/documents/hut1_12v2.pdf */
            #if GATEENGINE_DEBUG_HID
            case .keyboardInternational1: /* International1 */
                keyName = "keyboardInternational1"
            case .keyboardInternational2: /* International2 */
                keyName = "keyboardInternational2"
            case .keyboardInternational3: /* International3 */
                keyName = "keyboardInternational3"
            case .keyboardInternational4: /* International4 */
                keyName = "keyboardInternational4"
            case .keyboardInternational5: /* International5 */
                keyName = "keyboardInternational5"
            case .keyboardInternational6: /* International6 */
                keyName = "keyboardInternational6"
            case .keyboardInternational7: /* International7 */
                keyName = "keyboardInternational7"
            case .keyboardInternational8: /* International8 */
                keyName = "keyboardInternational8"
            case .keyboardInternational9: /* International9 */
                keyName = "keyboardInternational9"

            /* LANG1: On Apple keyboard for Japanese, this is the kana switch (かな) key */
            /* On Korean keyboards, this is the Hangul/English toggle key. */
            case .keyboardLANG1: /* LANG1 */
                keyName = "keyboardLANG1"

            /* LANG2: On Apple keyboards for Japanese, this is the alphanumeric (英数) key */
            /* On Korean keyboards, this is the Hanja conversion key. */
            case .keyboardLANG2: /* LANG2 */
                keyName = "keyboardLANG2"

            /* LANG3: Defines the Katakana key for Japanese USB word-processing keyboards. */
            case .keyboardLANG3: /* LANG3 */
                keyName = "keyboardLANG3"

            /* LANG4: Defines the Hiragana key for Japanese USB word-processing keyboards. */
            case .keyboardLANG4: /* LANG4 */
                keyName = "keyboardLANG4"

            /* LANG5: Defines the Zenkaku/Hankaku key for Japanese USB word-processing keyboards. */
            case .keyboardLANG5: /* LANG5 */
                keyName = "keyboardLANG5"

            /* LANG6-9: Reserved for language-specific functions, such as Front End Processors and Input Method Editors. */
            case .keyboardLANG6: /* LANG6 */
                keyName = "keyboardLANG6"
            case .keyboardLANG7: /* LANG7 */
                keyName = "keyboardLANG7"
            case .keyboardLANG8: /* LANG8 */
                keyName = "keyboardLANG8"
            case .keyboardLANG9: /* LANG9 */
                keyName = "keyboardLANG9"

            case .keyboardAlternateErase: /* AlternateErase */
                keyName = "keyboardAlternateErase"
            case .keyboardSysReqOrAttention: /* SysReq/Attention */
                keyName = "keyboardSysReqOrAttention"
            case .keyboardCancel: /* Cancel */
                keyName = "keyboardCancel"
            #endif
            case .keyboardClear: /* Clear */
                key = .clear
            #if GATEENGINE_DEBUG_HID
            case .keyboardPrior: /* Prior */
                keyName = "keyboardPrior"
            #endif
            case .keyboardReturn: /* Return */
                key = .enter(.standard)
            #if GATEENGINE_DEBUG_HID
            case .keyboardSeparator: /* Separator */
                keyName = "keyboardSeparator"
            case .keyboardOut: /* Out */
                keyName = "keyboardOut"
            case .keyboardOper: /* Oper */
                keyName = "keyboardOper"
            #endif
            case .keyboardClearOrAgain: /* Clear/Again */
                key = .clear
            #if GATEENGINE_DEBUG_HID
            case .keyboardCrSelOrProps: /* CrSel/Props */
                keyName = "keyboardCrSelOrProps"
            case .keyboardExSel: /* ExSel */
                keyName = "keyboardExSel"
            #endif

            /* 0xA5-0xDF: Reserved */

            case .keyboardLeftControl: /* Left Control */
                key = .control(.leftSide)
            case .keyboardLeftShift: /* Left Shift */
                key = .shift(.leftSide)
            case .keyboardLeftAlt: /* Left Alt */
                key = .alt(.leftSide)
            case .keyboardLeftGUI: /* Left GUI */
                key = .host(.leftSide)
            case .keyboardRightControl: /* Right Control */
                key = .control(.rightSide)
            case .keyboardRightShift: /* Right Shift */
                key = .shift(.rightSide)
            case .keyboardRightAlt: /* Right Alt */
                key = .alt(.rightSide)
            case .keyboardRightGUI: /* Right GUI */
                key = .host(.rightSide)

            /* 0xE8-0xFFFF: Reserved */
            #if GATEENGINE_DEBUG_HID
            case .keyboard_Reserved:
                break
            #endif

            default:
                break
            }

            let characters = pressKey.characters
            if key == nil {
                #if GATEENGINE_DEBUG_HID
                Log.warnOnce(
                    "Key Code \(pressKey.keyCode.rawValue)\(keyName != nil ? ":\(keyName!)" : "") is unhandled!"
                )
                #else
                Log.warnOnce("Key Code \(pressKey.keyCode.rawValue) is unhandled!")
                #endif
                key = .unhandledPlatformKeyCode(pressKey.keyCode.rawValue, characters.first)
            }
            keys.append((key!, characters))
        }
        return keys
    }

    @inlinable
    func modifiersFromEvent(_ event: UIPressesEvent) -> KeyboardModifierMask {
        var modifiers: KeyboardModifierMask = []
        for press in event.allPresses {
            guard let key = press.key else { continue }
            if key.modifierFlags.contains(.command) {
                modifiers.insert(.host)
            }
            if key.modifierFlags.contains(.control) {
                modifiers.insert(.control)
            }
            if key.modifierFlags.contains(.alternate) {
                modifiers.insert(.alt)
            }
            if key.modifierFlags.contains(.shift) {
                modifiers.insert(.shift)
            }
            if key.modifierFlags.contains(.alphaShift) {
                modifiers.insert(.capsLock)
            }
        }
        return modifiers
    }

    @inlinable
    func didHandlePressEvent(_ event: UIPressesEvent?, _ keyEvent: KeyboardEvent) -> Bool {
        var handled: Bool = false
        guard let event else { return handled }
        let keys = keysFromEvent(event)
        let modifiers = modifiersFromEvent(event)
        for pair in keys {
            if Game.shared.hid.keyboardDidHandle(
                key: pair.key,
                character: pair.characters?.first,
                modifiers: modifiers,
                isRepeat: false,
                event: keyEvent
            ) {
                handled = true
            }
        }
        return handled
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if didHandlePressEvent(event, .keyDown) == false {
            super.pressesBegan(presses, with: event)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if didHandlePressEvent(event, .keyUp) == false {
            super.pressesEnded(presses, with: event)
        }
    }

    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesChanged(presses, with: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if didHandlePressEvent(event, .keyUp) == false {
            super.pressesCancelled(presses, with: event)
        }
    }
}

// MARK: - Mouse
#if !os(tvOS)
@available(iOS 13.4, *)
extension UIKitViewController: UIPointerInteractionDelegate {

    // Called as the pointer moves within the interaction's view.
    func pointerInteraction(
        _ interaction: UIPointerInteraction,
        regionFor request: UIPointerRegionRequest,
        defaultRegion: UIPointerRegion
    ) -> UIPointerRegion? {
        Game.shared.hid.mouseChange(
            event: .moved,
            position: Position2(request.location),
            delta: .zero,
            window: self.window.window
        )
        return defaultRegion
    }

    // Called after the interaction receives a new UIPointerRegion from pointerInteraction:regionForRequest:defaultRegion:.
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion)
        -> UIPointerStyle?
    {
        if Game.shared.hid.mouse.hidden {
            return UIPointerStyle.hidden()
        }
        return nil
    }

    // Called when the pointer enters a given region.
    func pointerInteraction(
        _ interaction: UIPointerInteraction,
        willEnter region: UIPointerRegion,
        animator: any UIPointerInteractionAnimating
    ) {
        Game.shared.hid.mouseChange(
            event: .entered,
            position: .zero,
            delta: .zero,
            window: self.window.window
        )
    }

    // Called when the pointer exists a given region.
    func pointerInteraction(
        _ interaction: UIPointerInteraction,
        willExit region: UIPointerRegion,
        animator: any UIPointerInteractionAnimating
    ) {
        Game.shared.hid.mouseChange(
            event: .exited,
            position: .zero,
            delta: .zero,
            window: self.window.window
        )
    }
}
#endif
#endif

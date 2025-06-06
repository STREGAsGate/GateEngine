/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor
open class GestureRecognizer {
    public internal(set) weak var view: View? = nil
    public internal(set) var phase: Phase = .unrecognized
    public enum Phase {
        case unrecognized
        case recognizing
        case recognized
    }
    
    public var recognizedSources: Sources
    public struct Sources: OptionSet, Sendable {
        public var rawValue: UInt8
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        public static let mouse: Sources = .init(rawValue: 1 << 0)
        public static let screen: Sources = .init(rawValue: 1 << 1)
        public static let surface: Sources = .init(rawValue: 1 << 2)
        
        public static let all: Sources = [.mouse, .screen, .surface]
    }
    
    open func invalidate() {
        
    }
    
    open func recognizesSimultaneously(with otherGestureRecognizer: some GestureRecognizer) -> Bool {
        return false
    }
    
    nonisolated public init(recognizedSources: Sources) {
        self.recognizedSources = recognizedSources
    }
    
    open func touchesBegan(_ touches: Set<Touch>) {

    }
    open func touchesMoved(_ touches: Set<Touch>) {
        
    }
    open func touchesEnded(_ touches: Set<Touch>) {
        
    }
    open func touchesCanceled(_ touches: Set<Touch>) {
        
    }
    
    open func surfaceTouchesBegan(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    open func surfaceTouchesMoved(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    open func surfaceTouchesEnded(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    open func surfaceTouchesCanceled(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    
    open func cursorEntered(_ cursor: Mouse) {
        
    }
    open func cursorMoved(_ cursor: Mouse) {
        
    }
    open func cursorExited(_ cursor: Mouse) {
        
    }
    
    open func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        
    }
    open func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        
    }
    
    open func scrolled(_ delta: Position2, isPlatformGeneratedMomentum isMomentum: Bool) {
        
    }
}

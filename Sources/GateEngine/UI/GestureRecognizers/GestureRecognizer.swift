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
    
    open func invalidate() {
        
    }
    
    open func recognizesSimultaneously(with otherGestureRecognizer: some GestureRecognizer) -> Bool {
        return false
    }
    
    nonisolated public init() {
        
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

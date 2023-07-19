/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor public struct SpriteAnimation {
    public let duration: Float
    public var scale: Float = 1
    public var repeats: Bool
    
    internal let frameCount: Float?
    internal var spriteSheetStart: Position2
    internal var accumulatedTime: Float
    
    public var progress: Float {
        get {accumulatedTime / duration}
        set {accumulatedTime = duration * max(0, min(1, newValue))}
    }

    public var isFinished: Bool {
        if repeats {return false}
        return progress >= 1
    }

    /**
        Represents an animation for a cronologicallyordered and evenly spaced SpriteSheet
     
        Animations play left to right then down a row like most written languages. A sprite sheet can be a single row or many rows.
        The SpriteSheet can contain more then one animation, but each animation frame must be chronolocially ordered and evenly spaced.
     
        - parameter startColumn: the grid location on the x axis to for the first frame
        - parameter startRow: the grid location on the y axis to for the first frame
        - parameter frameCount: the number of frames in the animation. nil will cause the animation to play until the end
        - parameter duration: the amount of real time it should take to play the entire animation
        - parameter repeats: true is the animation should loop
     */
    public init(startColumn: UInt = 0, startRow: UInt = 0, frameCount: UInt? = nil, duration: Float, repeats: Bool = true) {
        if let frameCount {
            self.frameCount = Float(frameCount)
        }else{
            self.frameCount = nil
        }
        if duration == 0 {
            // make division by zero impossible
            self.duration = .leastNonzeroMagnitude
        }else{
            self.duration = duration
        }
        self.repeats = repeats
        self.spriteSheetStart = Position2(Float(startColumn), Float(startRow))
        self.accumulatedTime = 0
    }
    
    /**
        Represents an animation for a cronologicallyordered and evenly spaced SpriteSheet
     
        Animations play left to right then down a row like most written languages. A sprite sheet can be a single row or many rows.
        The SpriteSheet can contain more then one animation, but each animation frame must be chronolocially ordered and evenly spaced.
     
        - parameter startColumn: the grid location on the x axis to for the first frame
        - parameter startRow: the grid location on the y axis to for the first frame
        - parameter frameCount: the number of frames in the animation
        - parameter frameRate: the number of frames to play in 1 second
        - parameter repeats: true is the animation should loop
     */
    public init(startColumn: UInt = 0, startRow: UInt = 0, frameCount: UInt, frameRate: UInt, repeats: Bool = true) {
        self.frameCount = Float(frameCount)
        self.duration = Float(frameCount) / Float(frameRate)
        self.repeats = repeats
        self.spriteSheetStart = Position2(Float(startColumn), Float(startRow))
        self.accumulatedTime = 0
        assert(duration.isFinite && duration.isZero == false, "Computed duration must be greater then zero.")
    }

    public mutating func appendTime(_ deltaTime: Float) {
        accumulatedTime += deltaTime * scale
        while accumulatedTime > duration {
            if repeats {
                accumulatedTime -= duration
            }else{
                accumulatedTime = duration
            }
        }
    }
}

/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class SpriteComponent: Component {
    public var depth: Float = 0
    public var opacity: Float = 1
    public var tintColor: Color = .white

    public var spriteSheet: SpriteSheet?
    public var spriteRect: Rect
    public var spriteSize: Size2 {
        get {
            return self.spriteRect.size
        }
        set {
            self.spriteRect.size = newValue
        }
    }

    public var spriteCoordinate: Position2 {
        get {
            let x = self.spriteRect.position.x / self.spriteSize.width
            let y = self.spriteRect.position.y / self.spriteSize.height
            return Position2(x, y)
        }
        set {
            precondition(spriteSize != .zero, "spriteSize must be set first, and cannot be zero!")
            let x = self.spriteSize.width * newValue.x
            let y = self.spriteSize.height * newValue.y
            self.spriteRect.position = Position2(x, y)
        }
    }

    public var animations: [SpriteAnimation]
    public var activeAnimationIndex: Int? {
        return animationQueue.first
    }
    internal var activeAnimationIndexDidChange: Bool = true
    public var animationQueue: [Int] {
        didSet {
            self.moveToNextAnimationIfNeeded = false
            self.activeAnimationIndexDidChange = true
        }
    }
    internal var moveToNextAnimationIfNeeded: Bool = false
    public var activeAnimation: SpriteAnimation? {
        get {
            if let index = self.activeAnimationIndex {
                return self.animations[index]
            }
            return nil
        }
        set {
            if let newValue {
                if let index = self.activeAnimationIndex {
                    self.animations[index] = newValue
                }
            }else{
                self.clearAnimationQueue()
            }
        }
    }

    /// Appends the given animation index to the end of the animation queue.
    @inline(__always)
    public func queueAnimation(_ animationIndex: Int) {
        assert(animations.indices.contains(animationIndex), "Animations does not have index \(animationIndex).")
        animationQueue.append(animationIndex)
    }
    
    /// Replaces the entire animation queue with the given animation index.
    public func setAnimation(_ animationIndex: Int) {
        guard self.activeAnimationIndex != animationIndex else {return}
        assert(animations.indices.contains(animationIndex), "Animations does not have index \(animationIndex).")
        self.clearAnimationQueue()
        self.queueAnimation(animationIndex)
    }
    
    /// Removes all animations form the animation queue.
    @inline(__always)
    public func clearAnimationQueue() {
        animationQueue.removeAll(keepingCapacity: true)
    }

    public enum PlaybackState {
        /// Moves through the active animation over time
        case play
        /// Keeps the active animation locked on the current frame
        case pause
        /// Locks the active animation at the last frame next time it's encountered
        case pauseAtLoop
        /// Keeps the active animation locked on the first frame
        case stop
        /// Locks the active animation at the first frame next time it's encountered
        case stopAtLoop
        /// If the animation queue has another animation it will begin on the next last frame of the current animation
        case playNextAnimationAtLoop
    }
    public var playbackState: PlaybackState

    internal var previousCoordinate: Position2 = .zero
    
    @MainActor public func sprite() -> Sprite? {
        assert(spriteSize != .zero, "spriteSize cannot be zero.")
        
        if let animation = activeAnimation,
           let texture = spriteSheet?.texture,
           texture.state == .ready
        {
            let columns = texture.size.width / spriteSize.width
            let rows = texture.size.height / spriteSize.height
            let startFrame = (animation.spriteSheetStart.y * columns) + animation.spriteSheetStart.x
            let endFrame = {
                if let frameCount = animation.frameCount {
                    return startFrame + (frameCount - 1)
                }
                let framesInAnimation = (columns * rows) - startFrame
                return framesInAnimation
            }()
            let currentFrame = floor(
                startFrame.interpolated(to: endFrame, .linear(animation.progress))
            )
            
            let currentRow = floor(currentFrame / columns)
            let currentColumn = currentFrame - (columns * currentRow)
            let coord = Position2(currentColumn, currentRow)

            return spriteSheet?.sprite(at: coord, withSpriteSize: spriteSize)
        }
        // no animations, so return the first sprite
        return spriteSheet?.sprite(at: spriteCoordinate, withSpriteSize: spriteSize)
    }
    
    public init() { 
        self.spriteRect = .zero
        self.spriteSheet = nil
        self.animationQueue = [0]
        self.animations = []
        self.playbackState = .play
    }
    
    public init(spriteRect: Rect, spriteSheet: SpriteSheet, activeAnimationIndex: Int = 0, animations: [SpriteAnimation], playbackState: PlaybackState = .play) {
        self.spriteRect = spriteRect
        self.spriteSheet = spriteSheet
        self.animationQueue = [activeAnimationIndex]
        self.animations = animations
        self.playbackState = playbackState
    }

    public init(spriteSize: Size2, spriteSheet: SpriteSheet, activeAnimationIndex: Int = 0, animations: [SpriteAnimation], playbackState: PlaybackState = .play) {
        self.spriteRect = Rect(size: spriteSize)
        self.spriteSheet = spriteSheet
        self.animationQueue = [activeAnimationIndex]
        self.animations = animations
        self.playbackState = playbackState
    }

    public static let componentID: ComponentID = ComponentID()
}

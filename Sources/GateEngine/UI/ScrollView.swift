/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public extension ScrollView {
    struct ScrollDirection: OptionSet, Sendable {
        public let rawValue: UInt8
        
        public static let horizontal: Self = Self(rawValue: 1 << 1)
        public static let vertical: Self = Self(rawValue: 1 << 2)
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

open class ScrollView: View {
    public var scrollDirection: ScrollDirection = [.vertical]
    
    public var offset: Position2 = .zero {
        didSet {
            if offset != oldValue {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    var animationDuration: Float = 0.25
    var animationAccumulator: Float = 0
    var destinationOffset: Position2 = .zero
    
    public var contentView: View = View()

    open override func update(withTimePassed deltaTime: Float) {
        super.update(withTimePassed: deltaTime)
        animationAccumulator += deltaTime
        let factor: Float = .minimum(1, animationAccumulator / animationDuration)
        self.offset.interpolate(to: destinationOffset, .linear(factor))
    }
    
    override public init() {
        super.init()
        self.addSubview(contentView)
    }
    
    open override func updateLayoutConstraints() {
        super.updateLayoutConstraints()
        
        self.contentView.layoutConstraints.removeAllConstraints()
        self.contentView.topAnchor.constrain(offset.y, from: self.topAnchor)
        self.contentView.leadingAnchor.constrain(offset.x, from: self.leadingAnchor)
        self.contentView.bottomAnchor.constrain(offset.x, from: self.bottomAnchor)
        self.contentView.trailingAnchor.constrain(to: self.trailingAnchor)
    }
    
    open override func canBeHit() -> Bool {
        return true
    }
    
    open override func scrolled(_ delta: Position2, isPlatformGeneratedMomentum isMomentum: Bool) {
        super.scrolled(delta, isPlatformGeneratedMomentum: isMomentum)
        if isMomentum == false {
            if scrollDirection.contains(.horizontal) {
                destinationOffset.x = delta.x
            }
            if scrollDirection.contains(.vertical) {
                destinationOffset.y = delta.y
            }
        }
    }
    
//    open override func cursorExited(_ cursor: Mouse) {
//        destinationOffset = .zero
//        animationDuration = 0.3
//        animationAccumulator = 0
//    }
//    open override func cursorEntered(_ cursor: Mouse) {
//        animationAccumulator = 0
//        animationDuration = 0.3
//    }
//    open override func cursorMoved(_ cursor: Mouse) {
//        super.cursorMoved(cursor)
//        destinationOffset.y = cursor.loactionInView(self)?.y ?? 0
//    }
}

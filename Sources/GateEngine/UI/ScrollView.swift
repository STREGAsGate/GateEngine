/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

open class ScrollView: View {
    public var offset: Position2 = .zero {
        didSet {
            if offset != oldValue {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    var animationDuration: Float = 0.01
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
            destinationOffset += delta
            destinationOffset.x = .maximum(0, destinationOffset.x)
            destinationOffset.y = .maximum(0, destinationOffset.y)
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

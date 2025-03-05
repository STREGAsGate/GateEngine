/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

final class SplitViewDividerControl: Control {
    var isEnabled: Bool = true
    override func canBeHit() -> Bool {
        return isEnabled
    }
    
    let divider = View()
    
    var isDragging: Bool = false
    
    override init(size: Size2? = nil) {
        super.init(size: size)
        divider.backgroundColor = .darkGray
        self.addSubview(divider)
    }
    
    override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        super.cursorButtonDown(button: button, mouse: mouse)
        
        if button == .button1 {
            self.isDragging = true
            self.sendActions(forEvent: .changed)
        }
    }
    
    override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        super.cursorButtonUp(button: button, mouse: mouse)
        if button == .button1 {
            self.isDragging = false
            self.sendActions(forEvent: .changed)
        }
    }

    override func cursorEntered(_ cursor: Mouse) {
        super.cursorEntered(cursor)
        cursor.style = .resizeHorizontal
        cursorFixTimer?.invalidate()
    }
    
    var cursorFixTimer: Timer? = nil
    
    override func cursorMoved(_ cursor: Mouse) {
        super.cursorMoved(cursor)
        cursorFixTimer?.invalidate()
    }
    
    override func cursorExited(_ cursor: Mouse) {
        super.cursorExited(cursor)
        if isDragging {
            cursorFixTimer = .scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
                Task { @MainActor in 
                    cursor.style = .arrow
                }
            })
        }else{
            cursor.style = .arrow
        }
    }
    
    override func updateLayoutConstraints() {
        super.updateLayoutConstraints()
        
        self.divider.layoutConstraints.removeAllConstraints()
        self.divider.widthAnchor.constrain(to: 1)
        divider.topAnchor.constrain(to: self.topAnchor)
        divider.bottomAnchor.constrain(to: self.bottomAnchor)
        divider.centerXAnchor.constrain(to: self.centerXAnchor)
        
        self.widthAnchor.constrain(to: 8)
    }
}

public final class SplitView: View {
    public var canResizeSidebar: Bool = true {
        didSet {
            dividerControl.isEnabled = self.canResizeSidebar
        }
    }
    public var dividerXOffset: Float = 300 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    let dividerControl: SplitViewDividerControl = SplitViewDividerControl()
    public func addSidebarView(_ sidebarView: View, contentView: View) {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        self.addSubview(sidebarView)
        self.addSubview(contentView)
        self.addSubview(dividerControl)
    }
        
    public override init(size: Size2? = nil) {
        super.init(size: size)
 
    }
    
    public override func canBeHit() -> Bool {
        return true
    }
    
    public override func cursorMoved(_ cursor: Mouse) {
        super.cursorMoved(cursor)
        if dividerControl.isDragging {
            if cursor.button(.button1).isPressed {
                if let new = cursor.locationInView(self)?.x {
                    dividerXOffset = new
                }
            }
        }
    }
    
    public override func updateLayoutConstraints() {
        super.updateLayoutConstraints()

        dividerControl.layoutConstraints.removeAllConstraints()
        dividerControl.topAnchor.constrain(to: self.topAnchor)
        dividerControl.bottomAnchor.constrain(to: self.bottomAnchor)
        dividerControl.widthAnchor.constrain(to: 8)
        dividerControl.leadingAnchor.constrain(dividerXOffset - 4, from: self.leadingAnchor, priority: .high)
        
        self.subviews[0].layoutConstraints.removeAllConstraints()
        self.subviews[0].topAnchor.constrain(to: self.topAnchor)
        self.subviews[0].leadingAnchor.constrain(to: self.leadingAnchor)
        self.subviews[0].bottomAnchor.constrain(to: self.bottomAnchor)
        self.subviews[0].widthAnchor.constrain(to: dividerXOffset)
        
        self.subviews[1].layoutConstraints.removeAllConstraints()
        self.subviews[1].topAnchor.constrain(to: self.topAnchor)
        self.subviews[1].leadingAnchor.constrain(dividerXOffset + 1, from: self.leadingAnchor)
        self.subviews[1].bottomAnchor.constrain(to: self.bottomAnchor)
        self.subviews[1].trailingAnchor.constrain(to: self.trailingAnchor)
    }
}

open class SplitViewController: ViewController {
    @usableFromInline
    internal let context = ECSContext()

    final public override func loadView() {
        self.view = SplitView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.splitView.addSidebarView(children[0].view, contentView: children[1].view)
    }
    
    public var splitView: SplitView {
        return self.view as! SplitView
    }
    
    public init(sideBar: ViewController, content: ViewController) {
        super.init()
        self.addChildViewController(sideBar)
        self.addChildViewController(content)
    }
}

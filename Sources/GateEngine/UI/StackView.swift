/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension StackView {
    public enum Axis {
        case horizontal
        case vertical
    }
    public enum Distribution {
        case equalSpacing
    }
}

public final class StackView: View {
    public var axis: Axis {
        didSet {
            if axis != oldValue {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    public var distribution: Distribution {
        didSet {
            if distribution != oldValue {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    public var spacing: Float {
        didSet {
            if spacing != spacing {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    public init(axis: Axis, distribution: Distribution, spacing: Float, subviews: [View]) {
        self.axis = axis
        self.distribution = distribution
        self.spacing = spacing
        super.init()
        for view in subviews {
            self.addSubview(view)
        }
        self.needsUpdateConstraints = true
    }
    
    public override func contentSize() -> Size2 {
        switch axis {
        case .horizontal:
            return Size2(
                width: subviews.last?.frame.maxX ?? 0, 
                height: (subviews.sorted(by: {$0.bounds.height > $1.bounds.height}).first?.bounds.height ?? 0) + (spacing * Float(subviews.count - 1))
            )
        case .vertical:
            return Size2(
                width: (subviews.sorted(by: {$0.bounds.width > $1.bounds.width}).first?.bounds.width ?? 0) + (spacing * Float(subviews.count - 1)), 
                height: subviews.last?.frame.maxY ?? 0
            )
        }
    }
    
    public override func updateLayoutConstraints() {
        if subviews.isEmpty {
            self.widthAnchor.constrain(to: 0)
            self.heightAnchor.constrain(to: 0)
            return
        }
        switch axis {
        case .horizontal:
            switch distribution {
            case .equalSpacing:
                var previousView: View = self
                for subView in subviews {
                    subView.layoutConstraints.removeAllVerticalPositionConstraints()
                    subView.layoutConstraints.removeAllHorizontalPositionConstraints()
                    if previousView === self {
                        subView.leadingAnchor.constrain(to: self.leadingAnchor)
                    }else{
                        subView.leadingAnchor.constrain(spacing, from: previousView.trailingAnchor)
                    }
                    subView.centerYAnchor.constrain(to: self.centerYAnchor)
                    previousView = subView
                }
                subviews.last?.trailingAnchor.constrain(to: self.trailingAnchor)
            }
        case .vertical:
            switch distribution {
            case .equalSpacing:
                var previousView: View = self
                for subView in subviews {
                    subView.layoutConstraints.removeAllVerticalPositionConstraints()
                    subView.layoutConstraints.removeAllHorizontalPositionConstraints()
                    if previousView === self {
                        subView.topAnchor.constrain(to: self.topAnchor)
                    }else{
                        subView.topAnchor.constrain(spacing, from: previousView.bottomAnchor)
                    }
                    subView.leadingAnchor.constrain(to: self.leadingAnchor)
                    subView.trailingAnchor.constrain(to: self.trailingAnchor)
                    previousView = subView
                }
                subviews.last?.bottomAnchor.constrain(to: self.bottomAnchor)
            }
        }
    }
}


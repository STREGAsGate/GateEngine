/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

open class ImageView: View {
    public typealias SampleFilter = Material.Channel.SampleFilter
    
    internal var material = Material()
    public var sampleFilter: SampleFilter {
        get { 
            return material.channel(0) { channel in
                return channel.sampleFilter
            }
        }
        set {
            material.channel(0) { channel in
                channel.sampleFilter = newValue
            }
        }
    }
    
    private var subRect: Rect? = nil
    
    public init(path: String, meta: (textureSize: Size2, subRect: Rect)? = nil, sampleFilter: SampleFilter = .linear) {
        self.subRect = meta?.subRect
        self.material.channel(0) { channel in
            channel.texture = Texture(path: path, sizeHint: meta?.textureSize, mipMapping: .none)
            channel.sampleFilter = sampleFilter
            if let subRect = meta?.subRect {
                
                channel.setSubRect(subRect)
            }
        }
        super.init()
    }
    
    open override func updateLayoutConstraints() {
        let size = contentSize()
        self.layoutConstraints.removeAllHorizontalSizeConstraints()
        self.layoutConstraints.removeAllVerticalSizeConstraints()
        self.widthAnchor.constrain(to: size.width)
        self.heightAnchor.constrain(to: size.height)
    }
    
    public override func contentSize() -> Size2 {
        if let subRect {
            return subRect.size
        }
        if let texture = material.channels[0].texture, texture.sizeIsAvailable {
            return texture.size
        }
        return super.contentSize()
    }
    
    override func draw(_ rect: Rect, into canvas: inout UICanvas) {
        super.draw(rect, into: &canvas)
        
        canvas.insert(
            DrawCommand(
                resource: .geometry(.rectOriginTopLeft),
                transforms: [
                    Transform3(
                        position: Position3(rect.x, rect.y, 0),
                        scale: Size3(rect.width, rect.height, 1)
                    )
                ],
                material: material,
                vsh: .standard,
                fsh: .textureSample,
                flags: .userInterface
            )
        )
    }
}


/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

internal protocol SkinnedGeometryBackend: AnyObject {
    init(geometry: RawGeometry, skin: Skin)
}

/** Geometry represents a mangaed vertex buffer object.
It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
When this object deinitializes it's contents will also be removed from GPU memory.
*/
@MainActor public class SkinnedGeometry: OldResource {
    private var path: String?
    private var geometryOptions: GeometryImporterOptions?
    private var skinOptions: SkinImporterOptions?
    private var lastLoaded: Date?
    
    @RequiresState(.ready)
    internal var backend: SkinnedGeometryBackend! = nil
    
    @RequiresState(.ready)
    internal var skinJoints: [Skin.Joint]! = nil
    
    /// - returns: `true` if calling `reload()` will work
    /// - note: Only a resource created form a URL can be reloaded
    public var needsReload: Bool {
        #if SUPPORTS_HOTRELOADING
        guard let path = path else {return false}
        guard let lastLoaded = lastLoaded else {return false}

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return modified > lastLoaded
            }else{
                return false
            }
        }catch{
            print(error.localizedDescription)
            return false
        }
        #else
        return false
        #endif
    }
    
    /// - note: Only a resource created form a URL can be reloaded
    /// - returns: `true` if the resource will be reloaded
    @discardableResult
    public func reload() -> Bool {
        #if SUPPORTS_HOTRELOADING
        guard self.needsReload else {return false}
        self.load()
        return true
        #else
        return false
        #endif
    }
        
    public init(geometry: RawGeometry, skin: Skin) {
        self.path = nil
        self.geometryOptions = nil
        self.skinOptions = nil
        self.skinJoints = skin.joints
        super.init()
        
        #if DEBUG
        self._backend.configure(withOwner: self)
        self._skinJoints.configure(withOwner: self)
        #endif
        
        Task {
            let backend =  Self.createBackend(with: geometry, skin: skin)
            Task { @MainActor in
                self.backend = backend
                self.state = .ready
            }
        }
    }
    
    public init(path: String, geometryOptions: GeometryImporterOptions = .none, skinOptions: SkinImporterOptions = .none) {
        self.path = path
        self.geometryOptions = geometryOptions
        self.skinOptions = skinOptions
        super.init()
        
        #if DEBUG
        self._backend.configure(withOwner: self)
        self._skinJoints.configure(withOwner: self)
        #endif
        
        self.load()
    }
    
    private func load() {
        guard let path = path else {return}
        guard let geometryOptions = geometryOptions else {return}
        guard let skinOptions = skinOptions else {return}

        Task {
            do {
                let geometry = try await RawGeometry(path: path, options: geometryOptions)
                let skin = try await Skin(path: path, options: skinOptions)
                let backend =  Self.createBackend(with: geometry, skin: skin)
                Task { @MainActor in
                    self.skinJoints = skin.joints
                    self.backend = backend
                    self.state = .ready
                }
            }catch{
                Task { @MainActor in
                    #if DEBUG
                    print(error)
                    #endif
                    self.state = .failed(reason: "\(error)")
                }
            }
        }
    }
}

internal extension SkinnedGeometry {
    class func createBackend(with geometry: RawGeometry, skin: Skin) -> SkinnedGeometryBackend {
        #if canImport(MetalKit)
        return MetalGeometry(geometry: geometry, skin: skin)
        #elseif canImport(WebGL2)
        return WebGL2Geometry(geometry: geometry, skin: skin)
        #else
        #error("Not implemented.")
        #endif
    }
}

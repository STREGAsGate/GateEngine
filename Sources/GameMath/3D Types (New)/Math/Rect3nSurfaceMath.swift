/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Common opperations used on box types for surface calculations
public protocol Rect3nSurfaceMath {
    typealias ScalarType = Vector3n.ScalarType
    associatedtype Scalar: ScalarType
    
    var center: Position3n<Scalar> { get }
    var radius: Size3n<Scalar> { get }
}

public extension Rect3nSurfaceMath {
    var minPosition: Position3n<Scalar> {
        return center - radius
    }
    
    var maxPosition: Position3n<Scalar> {
        return center + radius
    }
    
    var size: Size3n<Scalar> {
        return radius * 2
    }
}

public extension Rect3nSurfaceMath where Scalar: Comparable {
    /**
     Locates a position on the surface of this box that is as close to the given point as possible.
     - parameter position: A point in space to use as an reference
     - returns: The point on the box's surface that is nearest to `p`
     */
    func nearestSurfacePosition(to position: Position3n<Scalar>) -> Position3n<Scalar> {
        let minPosition: Position3n<Scalar> = self.minPosition
        let maxPosition: Position3n<Scalar> = self.maxPosition
        
        var result: Position3n<Scalar> = .zero
        
        for i in 0 ..< 3 {
            var v: Scalar = position[i]
            let min: Scalar = minPosition[i]
            if v < min {
                v = min // v = max(v, b.min[i])
            }
            let max: Scalar = maxPosition[i]
            if v > max {
                v = max // v = min(v, b.max[i])
            }
            result[i] = v
        }
        
        return result
    }
}

public extension Rect3nSurfaceMath where Scalar: Comparable {
    @inlinable
    func contains(_ rhs: Position3n<Scalar>) -> Bool {
        let min = self.minPosition
        guard rhs.x >= min.x && rhs.y >= min.y && rhs.z >= min.z  else {return false}
        
        let max = self.maxPosition
        guard rhs.x < max.x && rhs.y < max.y && rhs.z < max.z else {return false}
        
        return true
    }
    
    @inlinable
    func contains<T: Rect3nSurfaceMath>(_ otherRect: T) -> Bool where T.Scalar == Scalar {
        guard self.contains(otherRect.minPosition) else {return false}
        guard self.contains(otherRect.maxPosition) else {return false}
        return true
    }
    
    @inlinable
    func contains(_ rhs: Position3n<Scalar>, withThreshold threshold: Scalar) -> Bool {
        let min = self.minPosition - threshold
        guard rhs.x >= min.x && rhs.y >= min.y && rhs.z >= min.z  else {return false}
        
        let max = self.maxPosition + threshold
        guard rhs.x < max.x && rhs.y < max.y && rhs.z < max.z else {return false}
        
        return true
    }
    
    @inlinable
    func contains<T: Rect3nSurfaceMath>(_ otherRect: T, withThreshold threshold: Scalar) -> Bool where T.Scalar == Scalar {
        guard self.contains(otherRect.minPosition, withThreshold: threshold) else {return false}
        guard self.contains(otherRect.maxPosition, withThreshold: threshold) else {return false}
        return true
    }
}

// MARK: Ray3nIntersectable
public extension Rect3nSurfaceMath where Scalar: Ray3nIntersectable.ScalarType {
    func intersection(of ray: Ray3n<Scalar>) -> Position3n<Scalar>? {
        let minPosition: Position3n<Scalar> = self.minPosition
        let maxPosition: Position3n<Scalar> = self.maxPosition
        
        var tmin: Scalar = (minPosition.x - ray.origin.x) / ray.direction.x
        var tmax: Scalar = (maxPosition.x - ray.origin.x) / ray.direction.x
        
        if tmin > tmax {
            Swift.swap(&tmin, &tmax)
        }
        
        var tymin: Scalar = (minPosition.y - ray.origin.y) / ray.direction.y
        var tymax: Scalar = (maxPosition.y - ray.origin.y) / ray.direction.y
        
        if tymin > tymax {
            Swift.swap(&tymin, &tymax)
        }
        
        if tmin > tymax || tymin > tmax {
            return nil
        }
        
        if tymin > tmin {
            tmin = tymin
        }
        
        if tymax < tmax {
            tmax = tymax
        }
        
        var tzmin: Scalar = (minPosition.z - ray.origin.z) / ray.direction.z
        var tzmax: Scalar = (maxPosition.z - ray.origin.z) / ray.direction.z
        
        if tzmin > tzmax {
            Swift.swap(&tzmin, &tzmax)
        }
        
        if tmin > tzmax || tzmin > tmax {
            return nil
        }
        
        if tzmin > tmin {
            tmin = tzmin
        }
        
        if tzmax < tmax {
            tmax = tzmax
        }
        let t: Scalar = Swift.min(tmin, tmax)
        guard t > 0 else {return nil}
        return ray.origin.moved(t, toward: ray.direction)
    }
}

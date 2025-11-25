/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// A protocol to make sure all the possible variations have the same interface
public protocol IDGeneratorProtocol: Sendable {
    associatedtype T: BinaryInteger & Sendable
    func generateID() -> T
    init(startValue: T)
}

#if canImport(Atomics)
public import Atomics
public struct IDGenerator<T: AtomicInteger & Sendable>: IDGeneratorProtocol {
    var value: ManagedAtomic<T>
    public init(startValue: T = 0) {
        value = ManagedAtomic<T>(startValue)
    }

    public func generateID() -> T {
        return value.loadThenWrappingIncrement(ordering: .relaxed)
    }
}
#elseif canImport(Foundation.NSLock)
import class Foundation.NSLock
public final class IDGenerator<T: BinaryInteger & Sendable>: IDGeneratorProtocol {
    // isolation is managed with a lock, so this is safe
    nonisolated(unsafe) var value: T = 0
    let lock = NSLock()

    public init(startValue: T = 0) {
        self.value = startValue
    }

    public func generateID() -> T {
        return lock.withLock {
            let value = value
            self.value += 1
            return value
        }
    }
}
#else
public final class IDGenerator<T: BinaryInteger & Sendable>: IDGeneratorProtocol {
    nonisolated(unsafe) var value: T = 0

    public init(startValue: T = 0) {
        self.value = startValue
    }

    public func generateID() -> T {
        let value = value
        self.value += 1
        return value
    }
}
#endif

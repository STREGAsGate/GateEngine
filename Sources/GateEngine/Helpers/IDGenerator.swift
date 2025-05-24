/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Atomics)
public import Atomics
#elseif canImport(Foundation.NSLock)
import class Foundation.NSLock
#endif

#if canImport(Atomics)
nonisolated public final class IDGenerator<T: AtomicInteger & Sendable> {
    var value: ManagedAtomic<T>

    public init(startValue: T = 0) {
        value = ManagedAtomic<T>(startValue)
    }

    public func generateID() -> T {
        return value.loadThenWrappingIncrement(ordering: .sequentiallyConsistent)
    }
}
#elseif canImport(Foundation.NSLock)
nonisolated public final class IDGenerator<T: BinaryInteger & Sendable> {
    var value: T = 0
    let lock = NSLock()

    public init(startValue: T = 0) {
        self.value = startValue
    }

    public func generateID() -> T {
        lock.lock()
        let value = value
        self.value += 1
        defer {
            lock.unlock()
        }
        return value
    }
}
#else
nonisolated public final class IDGenerator<T: BinaryInteger & Sendable> {
    var value: T = 0

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

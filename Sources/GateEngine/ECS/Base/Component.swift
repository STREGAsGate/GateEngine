/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Atomics.ManagedAtomic)
import class Atomics.ManagedAtomic
#elseif canImport(Foundation.NSLock)
import class Foundation.NSLock
#endif

public protocol Component {
    init()
    nonisolated static var componentID: ComponentID {get}
}

public struct ComponentID: Equatable, Hashable {
    let value: UInt16
    public init() {
        self.value = Self.generator.getValue()
    }
}

private extension ComponentID {
    final class Generator {
        #if canImport(Atomics.ManagedAtomic)
        var value: ManagedAtomic<UInt16> = ManagedAtomic<UInt16>(0)
        #elseif canImport(Foundation.NSLock)
        let lock = NSLock()
        var value: UInt16 = 0
        #else
        var value: UInt16 = 0
        #endif
        
        
        func getValue() -> UInt16 {
            #if canImport(Atomics.ManagedAtomic)
            return value.wrappingIncrementThenLoad(ordering: .sequentiallyConsistent)
            #elseif canImport(Foundation.NSLock)
            lock.lock()
            defer {
                lock.unlock()
            }
            value += 1
            return value
            #else
            value += 1
            return value
            #endif
        }
    }
    static let generator = Generator()
}

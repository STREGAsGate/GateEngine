/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

open class Control: View {
    open override func canBeHit() -> Bool {
        return true
    }
    
    public struct Event: OptionSet, Hashable {
        public var rawValue: RawValue
        
        public static let changed = Event(rawValue: 1 << 0)
        
        public typealias RawValue = UInt
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    private var eventActionStorage: [Event: [()->()]] = [:]
    
    public final func sendActions(forEvent event: Event) {
        for block in eventActionStorage[event] ?? [] {
            block()
        }
    }
    
    public final func valueChanged(completion: @escaping ()->()) {
        var array = eventActionStorage[.changed] ?? []
        array.append(completion)
        eventActionStorage[.changed] = array
    }
}



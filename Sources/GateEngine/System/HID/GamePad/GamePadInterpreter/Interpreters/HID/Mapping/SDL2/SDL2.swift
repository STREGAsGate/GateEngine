/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS) || os(Windows) || os(Linux)

import Foundation

struct SDL2DatabaseError: Error, CustomStringConvertible {
    let description: String
    init(_ string: String) {
        self.description = string
    }
}

public struct SDL2ControllerGUID: Equatable, Hashable, CustomStringConvertible {
    public let guid: String
    public let vendor: Int
    public let product: Int
    public init?(_ guid: String, vendor: Int = 0, product: Int = 0) {
        guard guid.count == 32 else {return nil}
        guard CharacterSet(charactersIn: guid).subtracting(CharacterSet(charactersIn: "0123456789abcdef")).isEmpty else {return nil}
        self.guid = guid
        self.vendor = vendor
        self.product = product
    }
    
    public enum Transport: UInt16 {
        case unknown = 0x00
        case usb = 0x03
        case bluetooth = 0x05
        case virtual = 0xFF
    }
    
    public init(vendorID: Int, productID: Int, hidVersion: Int, transport: Int, name: String) {
        self.vendor = vendorID
        self.product = productID
        let transport: UInt16 = UInt16(littleEndian: UInt16(transport))
        let vendor: UInt16 = UInt16(littleEndian: UInt16(vendorID))
        let product: UInt16 = UInt16(littleEndian: UInt16(productID))
        let version: UInt16 = UInt16(littleEndian: UInt16(hidVersion))
        let crcname: UInt16 = name.withCString { cName in
            return UInt16(littleEndian: sdlCRC16(0, cName, name.utf8.count))
        }
        func sdlCRC16(_ crc: UInt16, _ data: UnsafePointer<Int8>, _ len: Int) -> UInt16 {
            func crc16_for_byte(_ r: UInt8) -> UInt16 {
                var r = r
                var crc: UInt16 = 0
                for _ in 0 ..< 8 {
                    crc = ((((UInt8(truncatingIfNeeded: crc) ^ r) & 1) != 0) ? 0xA001 : 0) ^ crc >> 1
                    r >>= 1
                }
                return crc
            }
            var crc = crc
            for i in 0 ..< len {
                crc = crc16_for_byte(UInt8(truncatingIfNeeded: crc) ^ UInt8(bitPattern: data[i])) & crc >> 8
            }
            return crc
        }
        
        self.guid = [transport, crcname, vendor, 0, product, 0, version, 0].withUnsafeBufferPointer({ pointer in
            var string: String = ""
            string.reserveCapacity(32)
            _ = Data(buffer: pointer).map({ byte in
                string += String(format: "%02lx", byte)
            })
            return string
        })
    }
    
    public var description: String {
        return guid
    }
    
    public static func ==(lhs: SDL2ControllerGUID, rhs: SDL2ControllerGUID) -> Bool {
        return lhs.guid == rhs.guid
    }
    public static func ==(lhs: SDL2ControllerGUID, rhs: String) -> Bool {
        return lhs.guid == rhs
    }
    public static func ==(lhs: String, rhs: SDL2ControllerGUID) -> Bool {
        return lhs == rhs.guid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(guid)
    }
}

struct SDL2ControllerMap {
    var id: SDL2ControllerGUID
    let name: String?
    let elements: [Element : Value]
    
    enum Element: String, Hashable {
        case menuBack = "back"
        case menuStart = "start"
        case menuGuid = "guide"
        
        case dPadUp = "dpup"
        case dPadDown = "dpdown"
        case dPadLeft = "dpleft"
        case dPadRight = "dpright"
        
        case buttonA = "a"
        case buttonB = "b"
        case buttonX = "x"
        case buttonY = "y"

        case shoulderL = "leftshoulder"
        case shoulderR = "rightshoulder"
        
        case triggerL = "lefttrigger"
        case triggerR = "righttrigger"
        
        case stickLAxisX = "leftx"
        case stickLAxisY = "lefty"
        case buttonStickL = "leftstick"

        case stickRAxisX = "rightx"
        case stickRAxisY = "righty"
        case buttonStickR = "rightstick"
    }
    
    struct Value {
        enum Kind {
            case button
            case hat(position: Int)
            enum Axis {
                case positive
                case negative
                case whole
                case wholeInverted
            }
            case analog(axis: Axis)
        }
        let kind: Kind
        let id: Int
        
        init?(_ string: String) {
            let kinds = CharacterSet(charactersIn: "abh")
            guard let k = string.unicodeScalars.first(where: {kinds.contains($0)}) else {return nil}

            switch k {
            case "b":
                kind = .button
                let e = string[string.index(after: string.startIndex)...]
                guard let elementID = Int(e) else {return nil}
                self.id = elementID
            case "a":
                var axis: Kind.Axis = .whole
                if string.contains("~") {
                    axis = .wholeInverted
                }else if string.hasPrefix("-") {
                    axis = .negative
                }else if string.hasPrefix("+") {
                    axis = .positive
                }
                kind = .analog(axis: axis)
                let e = string[string.index(after: string.startIndex)...]
                guard let elementID = Int(e) else {return nil}
                self.id = elementID
            case "h":
                let elements = string[string.index(after: string.startIndex)...]
                
                let values = elements.components(separatedBy: ".")
                
                guard let elementIDString = values.first else {return nil}
                guard let elementID = Int(elementIDString) else {return nil}
                self.id = elementID
                
                guard let hatPositionString = values.last else {return nil}
                guard let hatPosition = Int(hatPositionString) else {return nil}
                kind = .hat(position: hatPosition)
            default:
                return nil
            }
        }
    }

    func symbols() -> GamePadSymbolMap {
        guard let name = name else {return .unknown}
        let comps = Set(name.components(separatedBy: CharacterSet.whitespacesAndNewlines))
        if name.contains("8BitDo") {
            if comps.intersection(["SN30", "SNES30", "SF30", "SFC30"]).isEmpty == false {
                return .nintendoSwitch
            }
        }else if comps.intersection(["Sony", "PlayStation", "PS", "PS5", "PS4", "PS3", "PS2", "PS1", "Vita", "PSP"]).isEmpty == false {
            return .sonyPlaystation
        }else if comps.intersection(["Microsoft", "Xbox", "X360", "XInput"]).isEmpty == false {
            return .microsoftXbox
        }else if comps.intersection(["SNES", "NES", "3DS", "Famicom"]).isEmpty == false {
            return .nintendoClassic
        }else if comps.intersection(["GameCube"]).isEmpty == false {
            return .nintendoGameCube
        }else if comps.intersection(["Nintendo", "Joy-Con"]).isEmpty == false {
            return .nintendoSwitch
        }
        
        switch self.id.guid {
        case "03000000110100002014000001000000":// Mac OS X, SteelSeries Nimbus
            return .appleMFI
        default:
            return .unknown
        }
    }
}

class SDL2Database {
    var controllers: [SDL2ControllerGUID : SDL2ControllerMap] = [:]

    init() throws {
        let localURL = Bundle.module.resourceURL!.appendingPathComponent("GateEngine/SDL2_DB.txt")
        let string = try String(contentsOf: localURL)
        
        #if os(macOS)
        let platform = "Mac OS X"
        #elseif os(Windows)
        let platform = "Windows"
        #elseif os(Linux)
        let platform = "Linux"
        #elseif os(iOS) || os(tvOS)
        let platform = "iOS"
        #elseif os(Android)
        let platform = "Android"
        #else
        throw SDL2DatabaseError("Platfrom not supported.")
        #endif
                
        var controllers: [SDL2ControllerGUID : SDL2ControllerMap] = [:]
    
        for line in string.components(separatedBy: "\n") {
            guard line.indices.contains(line.startIndex) && line[line.startIndex] != "#" else {continue}
            guard line.contains("platform:\(platform)") else {continue}
            let line = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let elementStrings = line.components(separatedBy: ",")
            guard elementStrings.isEmpty == false else {continue}
            guard let guid = SDL2ControllerGUID(elementStrings[0]) else {continue}
            
            let name: String? = {
                if elementStrings.count > 1 {
                    let name = elementStrings[1]
                    if name.isEmpty == false {
                        return name
                    }
                }
                return nil
            }()
            
            var elements: [SDL2ControllerMap.Element : SDL2ControllerMap.Value] = [:]
            
            for elementString in elementStrings {
                let values = elementString.components(separatedBy: ":")
                guard values.count == 2 else {continue}
                guard let element = SDL2ControllerMap.Element(rawValue: values[0]) else {continue}
                guard let value = SDL2ControllerMap.Value(values[1]) else {continue}
                elements[element] = value
            }
            
            controllers[guid] = SDL2ControllerMap(id: guid, name: name, elements: elements)
        }
        
        #if GATEENGINE_DEBUG_HID
        Log.info("Parsed \(controllers.count) SDL2 DB Gamepads for \(platform).")
        #endif

        self.controllers = controllers
    }
//    
//    static let shared: SDL2Database? = {
//        do {
//            return try SDL2Database()
//        }catch{
//            print(error)
//            return nil
//        }
//    }()

    deinit {

    }
}
#endif

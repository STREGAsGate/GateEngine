/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Game {
    struct Info: Sendable {
        public let identifier: String = Game.unsafeShared.delegate.resolvedGameIdentifier()
        
        public var executableName: String {
            if let executableName = executableURL?.lastPathComponent {
                return executableName
            }
            return "[Unknown]"
        }
        
        public let executableURL: URL? = {
            if let path = CommandLine.arguments.first {
                let url: URL
                if #available(macOS 13.0, iOS 16.0, tvOS 15.0, *) {
                    url = URL(filePath: path, directoryHint: .notDirectory)
                } else {
                    url = URL(fileURLWithPath: path, isDirectory: false)
                }
                return url
            }
            return nil
        }()
    }
}

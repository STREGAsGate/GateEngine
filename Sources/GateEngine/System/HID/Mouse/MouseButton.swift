/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum MouseButton: Hashable {
    case button1
    case button2
    case button3
    case button4
    case button5
    case unknown(_ index: Int?)
    
    public static let primary: Self = .button1
    public static let secondary: Self = .button2
    public static let middle: Self = .button3
    public static let backward: Self = .button4
    public static let forward: Self = .button5
}

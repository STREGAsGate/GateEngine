/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@_exported import GameMath
@_exported import Atomics
@_exported import Collections

extension String: Error {}

#if targetEnvironment(macCatalyst)
#error("macCatalyst is not a supported platform.")
#endif

public extension GameMath.Color {
    static let vertexColors = Color(red: -1001, green: -2002, blue: -3003, alpha: -4004)
    static let defaultDiffuseMapColor = Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    static let defaultNormalMapColor = Color(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
    static let defaultRoughnessMapColor = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let defaultPointLightColor = Color(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
    static let defaultSpotLightColor = Color(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
    static let defaultDirectionalLightColor = Color(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
}

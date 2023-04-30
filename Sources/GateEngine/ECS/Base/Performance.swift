/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

extension ECSContext {
    @MainActor internal final class Performance {
        var totalDroppedFrames: Int = 0
        var fps: Int = 0
        private var _fpsStart: Double = 0
        private var _fpsCount: Int = 0
        
        private var _systemsStart: Double = 0
        private var _systemsFrameTime: Double = 0
        var systemsFrameTime: Double = 0
        
        private var _renderingSystemsStart: Double = 0
        private var _renderingSystemsFrameTime: Double = 0
        var renderingSystemsFrameTime: Double = 0
        
        private var cumulatedStatistics: Array<Array<Statistic>> = Array(repeating: [], count: 15)
        var currentIndex: Int = 0

        public func averageSortedStatistics() -> [Dictionary<String,Double>.Element] {
            calculateAverageStatistics()
            return averageStatistics.sorted(by: {$0.value > $1.value})
        }

        private var averageStatistics: [String:Double] = [:]
        private func calculateAverageStatistics() {
            averageStatistics.removeAll(keepingCapacity: true)
            var counts: [String:Int] = [:]
            for statistics in cumulatedStatistics {
                for statisic in statistics {
                    let key = "\(statisic.system)"
                    if averageStatistics[key] == nil {
                        averageStatistics[key] = statisic.duration
                    }else{
                        averageStatistics[key]! += statisic.duration
                    }
                    counts[key] = (counts[key] ?? 0) + 1
                }
            }

            for key in averageStatistics.keys {
                averageStatistics[key]! /= Double(counts[key]!)
            }
        }

        func prepareForReuse() {
            currentIndex += 1
            if currentIndex >= cumulatedStatistics.indices.upperBound {
                currentIndex = 0
            }
            cumulatedStatistics[currentIndex].removeAll(keepingCapacity: true)
        }

        public private(set) var currentStatistic: Statistic? = nil
        @inlinable
        func beginStatForSystem(_ system: System) {
            self.currentStatistic = Statistic(startWithSystem: system)
        }
        @inlinable
        func beginStatForSystem(_ system: PlatformSystem) {
            self.currentStatistic = Statistic(startWithSystem: system)
        }
        @inlinable
        func beginStatForSystem(_ system: RenderingSystem) {
            self.currentStatistic = Statistic(startWithSystem: system)
        }
        @inlinable
        func endCurrentStatistic() {
            self.currentStatistic?.end()
            if let currentStatistic = currentStatistic {
                self.cumulatedStatistics[currentIndex].append(currentStatistic)
            }
            self.currentStatistic = nil
        }

        @MainActor public struct Statistic {
            public let system: String
            private let startDate: Double
            private var endDate: Double! = nil
            internal let kind: Kind
            enum Kind {
                case platform(_ phase: PlatformSystem.Phase)
                case project(_ phase: System.Phase)
                case rendering
            }

            @inlinable
            public var duration: Double {
                return endDate - startDate
            }

            init(startWithSystem system: PlatformSystem) {
                let type = type(of: system)
                self.kind = .platform(type.phase)
                self.system = "[P] \(type)"
                self.startDate = Game.shared.internalPlatform.systemTime()
            }
            init(startWithSystem system: System) {
                let type = type(of: system)
                self.kind = .project(type.phase)
                self.system = "\(type)"
                self.startDate = Game.shared.internalPlatform.systemTime()
            }
            init(startWithSystem system: RenderingSystem) {
                let type = type(of: system)
                self.kind = .rendering
                self.system = "[R] \(type)"
                self.startDate = Game.shared.internalPlatform.systemTime()
            }

            @inlinable
            mutating func end() {
                self.endDate = Game.shared.internalPlatform.systemTime()
            }
        }
        

        @inlinable
        func startSystems() {
            _systemsStart = Game.shared.internalPlatform.systemTime()
        }
        @inlinable
        func endSystems() {
            _systemsFrameTime += Game.shared.internalPlatform.systemTime() - _systemsStart
        }
        @inlinable
        func finalizeSystemsFrameTime() {
            systemsFrameTime = _systemsFrameTime * 1000
            _systemsFrameTime = 0
        }
        
        @inlinable
        func startRenderingSystems() {
            _renderingSystemsStart = Game.shared.internalPlatform.systemTime()
        }
        @inlinable
        func endRenderingSystems() {
            _renderingSystemsFrameTime += Game.shared.internalPlatform.systemTime() - _systemsStart
            
            _fpsCount += 1
            let now = Game.shared.internalPlatform.systemTime()
            let duration = now - _fpsStart
            if duration > 1 {
                fps = _fpsCount
                _fpsStart = now
                _fpsCount = 0
            }
        }
        @inlinable
        func finalizeRenderingSystemsFrameTime() {
            renderingSystemsFrameTime = _renderingSystemsFrameTime * 1000
            _renderingSystemsFrameTime = 0
        }
    }
}

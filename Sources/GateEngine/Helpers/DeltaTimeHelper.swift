/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Assits in creating fixed step deltaTime values
internal struct DeltaTimeHelper {
    internal let name: String
    internal var limitFPS = false
    private var accumulator: Double = 0
    private var previousTime: Double = .nan
    private var currentSimulationSteps: Int = Self.preferredSimulationSteps {
        didSet {
            if currentSimulationSteps < 0 {
                // bottom out at zero so we can't get too low
                currentSimulationSteps = 0
            }else if currentSimulationSteps > Self.preferredSimulationSteps + Self.minSimulationSteps {
                // Allow the simulation to run slightly smoother then preffered
                currentSimulationSteps = Self.preferredSimulationSteps + Self.minSimulationSteps
            }
        }
    }
    
    private static let minimumFrameRate: Int = Platform.current.minimumFrameRate()
    private static let minSimulationSteps: Int = 2
    private static let minimumStepDuration: Double = {
        let literalDuration = (1 / Double(minimumFrameRate) / Double(minSimulationSteps))
        // make sure the minimum duration is divisible by the preferred duration
        let minDuration = literalDuration - literalDuration.truncatingRemainder(dividingBy: Self.preferredStepDuration)
        if minDuration < Self.preferredStepDuration {
            // If minDuration is somehow less then preferred, use the preferred
            return Self.preferredStepDuration
        }
        return minDuration
    }()

    private static let preferredFrameRate: Int = Platform.current.prefferedFrameRate()
    private static let preferredSimulationSteps: Int = 4
    private static let preferredStepDuration: Double = 1 / Double(preferredFrameRate) / Double(preferredSimulationSteps)
    
    internal init(name: String) {
        self.name = name
        self.reset()
    }
    
    /**
     Revert to initial state.
     
     `DeltaTimeHelper` stores time to compute deltaTime.
     Use this function to clear the stored time when it is known to be stale.
     */
    @inlinable mutating func reset() {
        self.previousTime = .nan
    }
    
    /**
     Computes a fixed step deltaTime based on the current platform
     - returns A fixed step deltaTime, or nil if the number of steps was zero.
     */
    @MainActor
    @inlinable mutating func getFixedStepDeltaTime() -> (steps: Int, deltaTime: Double)? {
        let currentTime = Platform.current.systemTime()
        if self.previousTime.isFinite == false {
            self.previousTime = currentTime
            return nil
        }
        
        // Determine the new accumulator value
        var literalDeltaTime: Double = (currentTime - self.previousTime) + self.accumulator
        
        // If our accumulated time is less than a single step, bail
        if literalDeltaTime < Self.preferredStepDuration {
            return nil
        }
        
        if limitFPS {
            if literalDeltaTime < 1 / Double(Self.minimumFrameRate) {
                return nil
            }
        }
        
        // Update previousTime if we get this far
        // No matter what, we'll start from now with the next measurment
        self.previousTime = currentTime
        
        let newRemainder = literalDeltaTime.truncatingRemainder(dividingBy: Self.preferredStepDuration)
        if newRemainder.isFinite {
            // Store the new accumulated remainder
            self.accumulator = newRemainder
            // Remove the new remainder from the current deltaTime
            literalDeltaTime = (literalDeltaTime - self.accumulator)
        }
        
        // If our accumulated time is not a number, bail
        if literalDeltaTime.isFinite == false {
            return nil
        }
        
        // The number of steps that currently fit in the accumulator
        let stepsRequired = Int(literalDeltaTime / Self.preferredStepDuration)
        
        // If stepsRequired is greater than maxSimulationSteps, then truncate.
        if stepsRequired > self.currentSimulationSteps {
            self.currentSimulationSteps -= 1
            
            if self.currentSimulationSteps < Self.minSimulationSteps {
                #if !DISTRIBUTE
                let seconds = Self.preferredStepDuration * Double(stepsRequired)
                if seconds > 1 / Double(Self.minimumFrameRate) {
                    // This issue is similar in severity to a dropped frame and will happen if the simulation is lagging.
                    // To reduce occurances of this, do less work.
                    // Try spreading work out across multiple updates.
                    let message = "\(name) needed \(stepsRequired) steps, and was truncated to \(Self.minSimulationSteps)."
                    Log.warn(message, "This is a \(String(format: "%0.3f", Self.preferredStepDuration * Double(stepsRequired))) second hang!")
                }
                #endif
                
                // Split the literalDeltaTime into the minimum steps
                let deltaTime = literalDeltaTime / Double(Self.minSimulationSteps)
                
                return (Self.minSimulationSteps, deltaTime)
            }
            
            let minStepsRequired = Int(literalDeltaTime / Self.minimumStepDuration)
            return (minStepsRequired, literalDeltaTime  / Double(minStepsRequired))
        }else{
            currentSimulationSteps += 1
        }
        
        return (self.currentSimulationSteps, literalDeltaTime / Double(self.currentSimulationSteps))
    }
    
    /**
     Computes a fixed step deltaTime based on the current platfo
     - returns A fixed step deltaTime, or nil if the number of steps was zero.
     */
    @MainActor
    @inlinable mutating func getDeltaTime() -> Double {
        guard let fixedStepDeltaTime = self.getFixedStepDeltaTime() else {return 1 / Double(Self.preferredFrameRate)}
        let deltaTime = fixedStepDeltaTime.deltaTime * Double(fixedStepDeltaTime.steps)
        if deltaTime.isFinite == false {
            return 1 / Double(Self.preferredFrameRate)
        }
        return deltaTime
    }
}

/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Assits in creating fixed step deltaTime values
internal struct DeltaTimeHelper {
    internal let name: String
    private var previousTime: Double = .nan
    
    private static let preferredFrameRate: Int = Platform.current.prefferedFrameRate()
    private static let simulationStepDuration: Double = 1 / Double(preferredFrameRate) / 4.10
    private static let maxSimulationSteps: Int = 4

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
     Computes a fixed step deltaTime based on the current platfo
     - returns A fixed step deltaTime, or nil if the number of steps was zero.
     */
    @MainActor
    @inlinable mutating func getFixedStepDeltaTime() -> (steps: Int, deltaTime: Double)? {
        let currentTime = Platform.current.systemTime()
        
        // Determine the new accumulator value
        let literalDeltaTime: Double = currentTime - self.previousTime

        // If our accumulated time is less than a single step, bail
        if literalDeltaTime < Self.simulationStepDuration {
            return nil
        }
        
        // Update previousTime if we get this far
        self.previousTime = currentTime
        
        // If our accumulated time is not a number, bail
        if literalDeltaTime.isFinite == false {
            return nil
        }
        
        // The number of steps that currently fit in the accumulator
        let stepsRequired = Int(literalDeltaTime / Self.simulationStepDuration)
        
        // If stepsRequired is greater than maxSimulationSteps, then truncate.
        if stepsRequired > Self.maxSimulationSteps {
            #if !DEBUG && !DISTRIBUTE
            // Anytime we return from here, the simulation is running slower.
            // This is similar in severity to a dropped frame and will happen if the simulation is lagging.
            // To reduce occurances of this, do less work.
            // Try spreading work out across multiple updates.
            let message = "\(name) needed \(stepsRequired) steps, and was truncated to \(Self.maxSimulationSteps)."
            if stepsRequired > Self.maxSimulationSteps * 2 {
                Log.warn(message, "This is a \(String(format: "%0.3f", Self.simulationStepDuration * Double(stepsRequired))) second hang!")
            }
            #endif
            
            // Return the maximum allowed deltaTime
            return (Self.maxSimulationSteps, Self.simulationStepDuration)
        }
 
        return (stepsRequired, Self.simulationStepDuration)
    }
    
    /**
     Computes a fixed step deltaTime based on the current platfo
     - returns A fixed step deltaTime, or nil if the number of steps was zero.
     */
    @MainActor
    @inlinable mutating func getDeltaTime() -> Double? {
        guard let fixedStepDeltaTime = self.getFixedStepDeltaTime() else {return nil}
        return fixedStepDeltaTime.deltaTime * Double(fixedStepDeltaTime.steps)
    }
}

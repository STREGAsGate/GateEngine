/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal struct DeltaTimeHelper {
    internal let name: String
    private var accumulator: Double = 0
    private var previousTime: Double = .nan
    
    private static let preferredFrameRate: Int = Platform.current.prefferedFrameRate()
    private static let simulationStepDuration: Double = 1 / Double(preferredFrameRate) / 2
    private static let maxSimulationSteps: Int = 4

    internal init(name: String) {
        self.name = name
        self.reset()
    }
    
    mutating func reset() {
        self.accumulator = 0
        self.previousTime = .nan
    }
    
    @MainActor
    @inlinable
    mutating func getDeltaTime() -> Double? {
        let currentTime = Platform.current.systemTime()
        
        // Determine the new accumulator value
        let newAccumulator: Double = self.accumulator + (currentTime - self.previousTime)

        // If our accumulated time is less than a single step, bail
        if newAccumulator < Self.simulationStepDuration {
            return nil
        }
        
        // Update previousTime if we get this far
        self.previousTime = currentTime
        
        // If our accumulated time is not a number, bail
        if newAccumulator.isFinite == false {
            return nil
        }
        
        // Update the accumulator
        self.accumulator = newAccumulator
        
        // The number of steps that currently fit in the accumulator
        let stepsRequired = Int(accumulator / Self.simulationStepDuration)
        
        // If stepsRequired is greater than maxSimulationSteps, return only that
        // Erase the accumulator as this is likely a spike from a CPU hang
        if stepsRequired > Self.maxSimulationSteps {
            // Anytime we return from here, the simulation will run slower.
            // This is similar in severity to a dropped frame and will happen if the simulation is lagging.
            // To reduce occurances of this, do less work.
            // Try spreading complex tasks out across multiple updates.
            let message = "\(name) deltaTime attempted to use \(stepsRequired) steps, and was truncated to \(Self.maxSimulationSteps)."
            if stepsRequired > 15 {
                Log.warn(message, "This is a \(String(format: "%0.3f", Self.simulationStepDuration * Double(stepsRequired))) second hang!")
            }else{
                Log.debug(message, "This is a minor performance issue.")
            }
            
            let maxSimulationSteps = Double(Self.maxSimulationSteps)
            
            // Zero the accumulator to give the next update the maximum time, becuase we just had a hang
            self.accumulator = 0
            
            // Return the maximum allowed deltaTime
            return Self.simulationStepDuration * maxSimulationSteps
        }
        
        // Calculate fixed step deltaTime
        let deltaTime = Self.simulationStepDuration * Double(stepsRequired)
        
        // Remove the used time from the accumulator
        self.accumulator -= deltaTime
        
        return deltaTime
    }
}

//
//  DrippingScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// A scene with a soundscape of dripping water (the menu and progress scenes)
class DrippingScene: Scene {

    /// Single water drips, played in random order
    private static let dripSounds = (1 ... 3).map {
        SKAction.playSoundFileNamed("Drip\($0).wav", waitForCompletion: false)
    }

    /// Soundscape of dripping water: a random drip every 1 to 3 seconds
    func startDripping() {
        let drip = SKAction.sequence([
            SKAction.wait(forDuration: 2.0, withRange: 2.0),
            SKAction.run { [weak self] in
                if let self, let sound = DrippingScene.dripSounds.randomElement() {
                    self.run(sound)
                }
            }])
        stopDripping()
        run(SKAction.repeatForever(drip), withKey: "drips")
    }

    func stopDripping() {
        removeAction(forKey: "drips")
    }
}

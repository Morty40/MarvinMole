//
//  Scene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Scene: SKScene {
    
    static let demoScene = DemoScene()
    static let floodScene = FloodScene()
    static let gameScene = GameScene()
    static let menuScene = MenuScene()
    static let progressScene = ProgressScene()

    override init() {
        super.init(size: CGSize(width: 1024, height: 768))
        backgroundColor = .black
        scaleMode = .aspectFit
        anchorPoint = .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transition(to scene: SKScene, animated: Bool = true) {
        if animated {
            let transition = SKTransition.chessboard(snakeDuration: 0.6, waitDuration: 0.4, from: self)
            //let transition = SKTransition.crossFade(withDuration: 0.1)
            view?.presentScene(scene, transition: transition)
        } else {
            view?.presentScene(scene)
        }
    }
    
    func handleKey(_ key: UIKey) {
    }
    
    var center: CGPoint {
        CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }

    /// Single water drips, played in random order
    private static let dripSounds = (1 ... 3).map {
        SKAction.playSoundFileNamed("Drip\($0).wav", waitForCompletion: false)
    }

    /// Soundscape of dripping water: a random drip every 1 to 3 seconds
    func startDripping() {
        let drip = SKAction.sequence([
            SKAction.wait(forDuration: 2.0, withRange: 2.0),
            SKAction.run { [weak self] in
                if let self, let sound = Scene.dripSounds.randomElement() {
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

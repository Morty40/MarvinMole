//
//  Scene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Scene: SKScene {
    
    static let menuScene = MenuScene(size: CGSize(width: 1024, height: 768))
    static let gameScene = GameScene(size: CGSize(width: 1024, height: 768))

    func transition(to scene: SKScene) {
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }
}

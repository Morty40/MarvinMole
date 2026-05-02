//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MenuScene: SKScene {
    
    
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        
        let backgroundImage = SKSpriteNode(imageNamed: "MenuBackground")
        backgroundImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundImage.size = CGSize(width: self.size.width, height: self.size.height)
        self.addChild(backgroundImage)                
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}

//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MenuScene: SKScene {
    
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "MenuBackground")
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        node.size = CGSize(width: size.width, height: size.height)
        return node
    }()
    
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(onTap)))
        
        addChild(backgroundImage)
    }
    
    @objc func onTap() {
        print("tap")
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}

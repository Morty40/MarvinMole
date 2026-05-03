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
    
    private lazy var startButton = {
        let node = Button(target: self, action: #selector(onStart))
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        return node
    }()
    
    @objc func onStart() {
        let transition = SKTransition.fade(with: .black, duration: 0.5)
        let newScene = GameScene()
        
        self.view!.presentScene(newScene,
                                transition: transition)
    }

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        
        backgroundImage.zPosition = 1
        addChild(backgroundImage)
        
        startButton.zPosition = 2
        addChild(startButton)
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}


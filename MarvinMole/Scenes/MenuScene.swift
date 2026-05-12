//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MenuScene: Scene {
    
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "MenuBackground")
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        node.size = CGSize(width: size.width, height: size.height)
        node.zPosition = 1
        return node
    }()
    
    private lazy var introText = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.fontSize = 30
        node.fontColor = .black
        node.position = CGPoint(x: frame.size.width * 0.09, y: frame.size.height * 0.78)
        node.preferredMaxLayoutWidth = 380
        node.horizontalAlignmentMode = .left
        node.verticalAlignmentMode = .top
        node.zPosition = 2
        node.text = "Oh dear! Marvin Mole's home is flooded and his food is all over the place.\n\nHelp him push his food back in the cupboards."
        node.numberOfLines = 0
        return node
    }()

    private lazy var startButton = {
        let node = TextButton(title: "Start", target: self, action: #selector(onStart))
        node.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.3)
        node.zPosition = 2
        return node
    }()
    
    @objc func onStart() {
        transition(to: Scene.gameScene)
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        anchorPoint = .zero
        
        addChild(backgroundImage)
        addChild(introText)
        addChild(startButton)
    }

    override func didMove(to view: SKView) {
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}


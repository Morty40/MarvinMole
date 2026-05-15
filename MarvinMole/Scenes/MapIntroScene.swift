//
//  MapIntroScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MapIntroScene: Scene {
            
    private lazy var mapTitleLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.fontSize = 60
        node.fontColor = .white
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.55)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.zPosition = 2
        node.text = "Easy 1"
        return node
    }()

    private lazy var mapDescriptionLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.fontSize = 50
        node.fontColor = .white
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.45)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.zPosition = 2
        node.text = "The tunnel trouble begins"
        return node
    }()

    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        backgroundColor = .black
        anchorPoint = .zero
        
        addChild(mapTitleLabel)
        addChild(mapDescriptionLabel)
    }

    override func didMove(to view: SKView) {
        run(SKAction.wait(forDuration: 1.5), completion: {
            self.transition(to: Scene.gameScene)
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}


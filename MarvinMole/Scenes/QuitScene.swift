//
//  QuitScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class QuitScene: Scene {
            
    private lazy var questionLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.fontSize = 40
        node.fontColor = .white
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.55)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.zPosition = 1
        node.text = "Are you sure you want to quit?"
        return node
    }()

    private lazy var yesButton = {
        let node = TextButton(title: "Yes", target: self, action: #selector(onYes))
        node.position = CGPoint(x: frame.size.width * 0.35, y: frame.size.height * 0.40)
        node.zPosition = 1
        return node
    }()
    
    @objc func onYes() {
        transition(to: Scene.menuScene)
    }

    private lazy var noButton = {
        let node = TextButton(title: "No", target: self, action: #selector(onNo))
        node.position = CGPoint(x: frame.size.width * 0.65, y: frame.size.height * 0.40)
        node.zPosition = 1
        return node
    }()
    
    @objc func onNo() {
        transition(to: Scene.gameScene)
    }

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        backgroundColor = .black
        anchorPoint = .zero
        
        addChild(questionLabel)
        addChild(yesButton)
        addChild(noButton)
    }
}


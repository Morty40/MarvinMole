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
    
    private lazy var startButton = {
        let node = TextButton(title: "Start", target: self, action: #selector(onStart))
        node.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.4)
        node.zPosition = 2
        return node
    }()
    
    @objc func onStart() {
        transition(to: Scene.gameScene)
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        print("sceneDidLoad: MenuScene")
        
        anchorPoint = .zero
        
        addChild(backgroundImage)
        addChild(startButton)
    }

    override func didMove(to view: SKView) {
        print("didMoveTo: MenuScene")
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}


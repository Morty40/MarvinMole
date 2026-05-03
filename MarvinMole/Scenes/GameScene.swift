//
//  GameScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class GameScene: Scene {
    
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "GameBackground")
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        node.size = CGSize(width: size.width, height: size.height)
        node.zPosition = 1
        return node
    }()
    
    private lazy var quitButton = {
        let node = Button(target: self, action: #selector(onQuit))
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        node.zPosition = 2
        return node
    }()
    
    @objc func onQuit() {
        transition(to: Scene.menuScene)
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        print("sceneDidLoad: GameScene")

        // setup gesture recognizers for four way navigation
        view?.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeUp),
                                     direction: .up))
        view?.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeDown),
                                     direction: .down))
        view?.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeLeft),
                                     direction: .left))
        view?.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeRight),
                                     direction: .right))
        
        anchorPoint = .zero
        
        addChild(backgroundImage)
        addChild(quitButton)
        
    }
    
    override func didMove(to view: SKView) {
        print("didMoveTo: GameScene")
    }
    
    @objc func onSwipeUp() {
        print("swipe up")
    }
    
    @objc func onSwipeDown() {
        print("swipe down")
    }
    
    @objc func onSwipeLeft() {
        print("swipe left")
    }
    
    @objc func onSwipeRight() {
        print("swipe right")
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}

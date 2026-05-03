//
//  GameScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class GameScene: SKScene {
        
    override func didMove(to view: SKView) {
                
        // setup gesture recognizers for four way navigation
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeUp),
                                     direction: .up))
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeDown),
                                     direction: .down))
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeLeft),
                                     direction: .left))
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeRight),
                                     direction: .right))
        
        anchorPoint = .zero
        
        let backgroundImage = SKSpriteNode(imageNamed: "GameBackground")
        backgroundImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundImage.size = CGSize(width: self.size.width, height: self.size.height)
        self.addChild(backgroundImage)                
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

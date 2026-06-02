//
//  Scene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Scene: SKScene {
    
    static let menuScene = MenuScene()
    static let mapIntroScene = MapIntroScene()
    static let gameScene = GameScene()
    static let quitScene = QuitScene()

    override init() {
        super.init(size: CGSize(width: 1024, height: 768))
        backgroundColor = .black
        scaleMode = .aspectFit
        anchorPoint = .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transition(to scene: SKScene) {
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }
    
    func handleKey(_ key: UIKey) {
    }
}

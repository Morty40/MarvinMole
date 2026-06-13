//
//  Scene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Scene: SKScene {
    
    static let demoScene = DemoScene()
    static let floodScene = FloodScene()
    static let gameScene = GameScene()
    static let loadingScene = LoadingScene()
    static let menuScene = MenuScene()
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
    
    func transition(to scene: SKScene, animated: Bool = true) {
        if animated {
            let transition = SKTransition.fade(withDuration: 0.3)
            //let transition = SKTransition.crossFade(withDuration: 0.1)
            view?.presentScene(scene, transition: transition)
        } else {
            view?.presentScene(scene)
        }
    }
    
    func handleKey(_ key: UIKey) {
    }
    
    var center: CGPoint {
        CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }
}

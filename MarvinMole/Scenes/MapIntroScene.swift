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
        node.zPosition = 1
        node.text = "<Title>"
        return node
    }()
    
    var title: String? {
        get { mapTitleLabel.text }
        set { mapTitleLabel.text = newValue }
    }
    
    private lazy var mapSubtitleLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.fontSize = 50
        node.fontColor = .white
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.45)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.zPosition = 1
        node.text = "<Subtitle>"
        return node
    }()
    
    var subtitle: String? {
        get { mapSubtitleLabel.text }
        set { mapSubtitleLabel.text = newValue }
    }
    
    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(mapTitleLabel)
        addChild(mapSubtitleLabel)
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        
        // move on to game scene automatically
        run(SKAction.wait(forDuration: 1.5), completion: {
            self.transition(to: Scene.gameScene)
        })
    }
    
}


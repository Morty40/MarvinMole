//
//  LoadingScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class LoadingScene: Scene {
    
    private var map: Map? = nil
    
    private lazy var titleLabel = {
        let node = SKLabelNode()
        node.fontName = "Rubik-Bold"
        node.fontSize = 60
        node.fontColor = .white
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.55)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.text = "<Title>"
        return node
    }()
        
    private lazy var subtitleLabel = {
        let node = SKLabelNode()
        node.fontName = "Rubik-Bold"
        node.fontSize = 50
        node.fontColor = .white
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.45)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.text = "<Subtitle>"
        return node
    }()
        
    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(titleLabel)
        addChild(subtitleLabel)
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        
        // move on to game scene automatically
        run(SKAction.wait(forDuration: 1.5), completion: {
            
            // prepare game scene, and transition
            Scene.gameScene.load(map: self.map!)
            self.transition(to: Scene.gameScene)
        })
    }
    
    func loadCurrentMap() {

        // load current map
        map = Map.mapFromBundle(resource: MapManager.shared.selectedMap.resourceName)

        // set title / subtitle
        titleLabel.text = String(format: "%@ %d",
                                 MapManager.shared.selectedMap.collection.title,
                                 MapManager.shared.selectedMap.number)
        subtitleLabel.text = map?.title
    }
}


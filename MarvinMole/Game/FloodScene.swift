//
//  FloodScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class FloodScene: Scene {
    
    private var map: Map = .empty
    
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "GameBackground")
        node.position = center
        node.size = size
        return node
    }()
    
    private lazy var mapView = {
        let node = MapView()
        node.position = center
        return node
    }()
    
    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(backgroundImage)
        addChild(mapView)
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        var floodingActions: [SKAction] = []
        
        let steps = map.size.width + map.size.height

        floodingActions.append(SKAction.wait(forDuration: 1.0))

        floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.alpha = 0.5
        })

        for i in 0 ... steps {
            let flooding = Double(i) / Double(steps)
            floodingActions.append(SKAction.run {
                self.mapView.waterTileMap.draw(map: self.map, flooding: flooding)
            })
            floodingActions.append(SKAction.wait(forDuration: 0.02))
        }

        floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.run(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
        })
        floodingActions.append(SKAction.wait(forDuration: 1.0))

        floodingActions.append(SKAction.run {
            self.mapView.boxContainer.isHidden = false
        })
        
        floodingActions.append(SKAction.wait(forDuration: 2.0))

        floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.run(SKAction.fadeAlpha(to: 0.0, duration: 3.0))
        })
        floodingActions.append(SKAction.wait(forDuration: 3.0))

        floodingActions.append(SKAction.wait(forDuration: 1.0))

        floodingActions.append(SKAction.run {
            self.transition(to: Scene.gameScene, animated: false)
        })

        let floodingSequence = SKAction.sequence(floodingActions)
        mapView.run(floodingSequence)
    }

    func load(map: Map) {
        self.map = map
        mapView.update(with: map)
        mapView.hero.isHidden = true
        mapView.boxContainer.isHidden = true
    }
    
    override func handleKey(_ key: UIKey) {
        // any key goes to the game
        transition(to: Scene.gameScene, animated: false)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        mapView.hero.update(currentTime)
        
    }

}

// TODO: add tap gesture recognizer, that transitions back to the menu. Check menu buttons are still working (bug?)

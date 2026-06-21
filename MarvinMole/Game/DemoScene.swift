//
//  DemoScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class DemoScene: Scene {
    
    private var startTime: TimeInterval = 0.0
    private var map: Map = .empty
    private var moves: [Map.Move] = []
    
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
        
        // load map from resource bundle
        let resource = String(format: "Classic%02d", 1)
        if let map = Map.mapFromBundle(resource: resource) {
            
            let moves = """
            ullluuuLUllDlldddrRRRRRRRRRRdrUllllllluuululldDDuu
            lldddrRRRRRRRRRRRRlllllllluuulLulDDDuulldddrRRRRRR
            RRRRRllllllluuulluuurDDuullDDDDDuulldddrRRRRRRRRRR
            uRRlDllllllluuuLLulDDDuulldddrRRRRRRRRRRdRRlUlllll
            lllllllulldRRRRRRRRRRRRRuRDldR
            """
            
            self.map = map
            self.moves = Map.movesFrom(lurd: moves)
            mapView.update(with: map)
        }
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        startTime = 0.0
    }
    
    override func handleKey(_ key: UIKey) {
        // any key goes back to the menu
        transition(to: Scene.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        mapView.hero.update(currentTime)
        
        if !mapView.hasActions() {
            
            if let move = moves.first {
                let movedObjects = map.makeMove(move)
                mapView.animateMovedObjects(movedObjects: movedObjects, move: move, map: map)
                moves.removeFirst()
                
            } else {
                mapView.hero.idle()
            }
        }
        
        // automatically go back to the menu after some time
        if startTime.isZero {
            startTime = currentTime
        } else if currentTime - startTime > 30.0 {
            transition(to: Scene.menuScene)
        }
        
    }

}

// TODO: add tap gesture recognizer, that transitions back to the menu. Check menu buttons are still working (bug?)

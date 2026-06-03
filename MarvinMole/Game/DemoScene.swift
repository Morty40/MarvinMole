//
//  DemoScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class DemoScene: Scene {
    
    private var map: Map = .empty
    private var pendingMoves: [Map.Move] = [.walkRight, .walkDown, .pushRight, .walkDown, .walkRight, .pushUp]
    
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
    
    func load(map: Map) {
        self.map = map
        mapView.update(with: map)
    }
    
    override func handleKey(_ key: UIKey) {
        // any key goes back to the menu
        transition(to: Scene.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        mapView.hero.update(currentTime)
        
        if !mapView.hasActions() {
            
            if let move = pendingMoves.first {
                let movedObjects = map.makeMove(move)
                mapView.animateMovedObjects(movedObjects: movedObjects, move: move, map: map)
                pendingMoves.removeFirst()
                
            } else {
                mapView.hero.idle()
            }
        }
    }

}

// TODO: add tap gesture recognizer, that transitions back to the menu. Check menu buttons are still working (bug?)

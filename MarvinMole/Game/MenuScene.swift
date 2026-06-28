//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MenuScene: Scene {
        
    private var startTime: TimeInterval = 0.0

    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "MenuBackground")
        node.position = center
        node.size = size
        return node
    }()
    
    private lazy var storyText = {
        let node = SKLabelNode()
        node.fontName = "Rubik-Bold"
        node.fontSize = 30
        node.fontColor = .black
        node.position = CGPoint(x: frame.size.width * 0.09, y: frame.size.height * 0.78)
        node.preferredMaxLayoutWidth = 380
        node.horizontalAlignmentMode = .left
        node.verticalAlignmentMode = .top
        node.text = "Oh dear! Marvin Mole's home is flooded and his food is all over the place.\n\nHelp him push his food back in the cupboards."
        node.numberOfLines = 0
        return node
    }()

    private lazy var solvedMapsText = {
        let node = SKLabelNode()
        node.fontName = "Rubik-Bold"
        node.fontSize = 30
        node.fontColor = .white
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.01)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.numberOfLines = 1
        return node
    }()

    private lazy var startButton = {
        let node = TextButton(title: "Start", target: self, action: #selector(onStart))
        node.position = CGPoint(x: frame.size.width * 0.22, y: frame.size.height * 0.35)
        return node
    }()
    
    @objc func onStart() {

        // reset idle timer
        startTime = 0.0
        
        MapManager.shared.save()

        // load current map and transition
        Scene.loadingScene.loadCurrentMap()
        transition(to: Scene.loadingScene)
    }

    private lazy var mapCollectionButton = {
        let node = TextButton(title: MapManager.shared.selectedMap.collection.title, target: self, action: #selector(onMapCollection))
        node.position = CGPoint(x: frame.size.width * 0.22, y: frame.size.height * 0.2)
        return node
    }()
    
    @objc func onMapCollection() {
        
        // reset idle timer
        startTime = 0.0
        
        var index = MapManager.MapCollection.allCases.firstIndex(of: MapManager.shared.selectedMap.collection)!
        index = (index + 1) % MapManager.MapCollection.allCases.count
        MapManager.shared.selectedMap.collection = MapManager.MapCollection.allCases[index]
        MapManager.shared.selectedMap.number = 1
        
        refreshSelectedMap()
    }

    private lazy var mapNumberButton = {
        let node = TextButton(title: "\(MapManager.shared.selectedMap.number)", target: self, action: #selector(onMapNumber))
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.2)
        return node
    }()
    
    @objc func onMapNumber() {
        
        // reset idle timer
        startTime = 0.0

        MapManager.shared.incrementMapNumber()

        refreshSelectedMap()
    }

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(backgroundImage)
        addChild(storyText)
        addChild(solvedMapsText)
        addChild(startButton)
        addChild(mapCollectionButton)
        addChild(mapNumberButton)
        
        refreshSelectedMap()
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        startTime = 0.0
        
        MapManager.shared.load()
        refreshSelectedMap()
        refreshSolvedMapsText()
    }
    
    private func refreshSelectedMap() {
        // map collection
        mapCollectionButton.title = MapManager.shared.selectedMap.collection.title

        // map number
        if let _ = MapManager.shared.mapSolutionFor(resourceName: MapManager.shared.selectedMap.resourceName) {
            mapNumberButton.title = "\(MapManager.shared.selectedMap.number) (solved)"

        } else {
            mapNumberButton.title = "\(MapManager.shared.selectedMap.number)"
        }
    }
    
    private func refreshSolvedMapsText() {
        let totalNumberOfMaps = MapManager.shared.totalNumberOfMaps
        let totalNumberOfSolvedMaps = MapManager.shared.totalNumberOfSolvedMaps
        if totalNumberOfSolvedMaps <= 0 {
            solvedMapsText.text = ""

        } else if totalNumberOfSolvedMaps >= totalNumberOfMaps {
            solvedMapsText.text = "You solved all the maps! Marvin is happy!"

        } else {
            solvedMapsText.text = "You solved \(totalNumberOfSolvedMaps) of \(totalNumberOfMaps) maps. Good job!"

        }
    }
        
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // automatically go demo mode after some time
        if startTime.isZero {
            startTime = currentTime
        } else if currentTime - startTime > 30.0 {
            transition(to: Scene.demoScene)
        }
    }

}

// TODO: update UI according to selected map

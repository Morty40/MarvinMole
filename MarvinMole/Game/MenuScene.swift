//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MapManager {
    static let shared = MapManager()

    private init() {}
    
    var currentMapNumber: Int = 1
    
    enum MapCollection: CaseIterable {
        case easy
        case medium
        case sokoban
        
        var title: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .sokoban: return "Classic"
            }
        }
        
        var count: Int {
            switch self {
            case .easy: return 3
            case .medium: return 3
            case .sokoban: return 50
            }
        }
        
        var fileName: String {
            switch self {
            case .easy: return "Easy%02d"
            case .medium: return "Medium%02d"
            case .sokoban: return "Sokoban%02d"
            }
        }
    }

    var currentMapCollection: MapCollection = .easy
    
    func incrementMapNumber() {
        currentMapNumber += 1
        if currentMapNumber > currentMapCollection.count {
            currentMapNumber = 1
        }
    }
}

class MenuScene: Scene {
        
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "MenuBackground")
        node.position = center
        node.size = size
        return node
    }()
    
    private lazy var introText = {
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

    private lazy var startButton = {
        let node = TextButton(title: "Start", target: self, action: #selector(onStart))
        node.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.35)
        return node
    }()
    
    @objc func onStart() {

        // load Sokoban map from resource bundle
        let resource = String(format: MapManager.shared.currentMapCollection.fileName, MapManager.shared.currentMapNumber)
        if let map = Map.mapFromBundle(resource: resource) {
            
            // prepare game scene
            Scene.gameScene.load(map: map)
            
            // prepare and go to map transistion scene
            Scene.introScene.subtitle = map.title
            transition(to: Scene.introScene)
        }
    }

    private lazy var mapCollectionButton = {
        let node = TextButton(title: MapManager.shared.currentMapCollection.title, target: self, action: #selector(onMapCollection))
        node.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.2)
        return node
    }()
    
    @objc func onMapCollection() {
        var index = MapManager.MapCollection.allCases.firstIndex(of: MapManager.shared.currentMapCollection)!
        index = (index + 1) % MapManager.MapCollection.allCases.count
        MapManager.shared.currentMapCollection = MapManager.MapCollection.allCases[index]
        mapCollectionButton.title = MapManager.shared.currentMapCollection.title
        MapManager.shared.currentMapNumber = 1
        mapNumberButton.title = "\(MapManager.shared.currentMapNumber)"
    }

    private lazy var mapNumberButton = {
        let node = TextButton(title: "\(MapManager.shared.currentMapNumber)", target: self, action: #selector(onMapNumber))
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.2)
        return node
    }()
    
    @objc func onMapNumber() {
        MapManager.shared.incrementMapNumber()
        mapNumberButton.title = "\(MapManager.shared.currentMapNumber)"
    }

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(backgroundImage)
        addChild(introText)
        addChild(startButton)
        addChild(mapCollectionButton)
        addChild(mapNumberButton)

        // TODO: remove
        /*
        for name in UIFont.familyNames {
            print(name)
            if let nameString = name as? String {
                print(UIFont.fontNames(forFamilyName: nameString))
            }
        }*/
        
    }
    
    override func handleKey(_ key: UIKey) {
        switch key.keyCode {
        case .keyboardD:
            
            // load Sokoban map from resource bundle
            let resource = String(format: "Sokoban%02d", 1)
            if let map = Map.mapFromBundle(resource: resource) {
                
                let moves = """
                ullluuuLUllDlldddrRRRRRRRRRRdrUllllllluuululldDDuu
                lldddrRRRRRRRRRRRRlllllllluuulLulDDDuulldddrRRRRRR
                RRRRRllllllluuulluuurDDuullDDDDDuulldddrRRRRRRRRRR
                uRRlDllllllluuuLLulDDDuulldddrRRRRRRRRRRdRRlUlllll
                lllllllulldRRRRRRRRRRRRRuRDldR
                """
                
                Scene.demoScene.load(map: map,
                                     moves: Map.movesFrom(lurd: moves))
                
                transition(to: Scene.demoScene)
            }
            
        default:
            break
        }
    }

}

// TODO: auto start demo mode after some idle time

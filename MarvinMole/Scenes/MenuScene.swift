//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MenuScene: Scene {
    
    enum MapCollection: CaseIterable {
        case easy
        case medium
        case hard
        
        var title: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            }
        }
    }
    private var mapCollection: MapCollection = .easy
    private var mapNumber: Int = 1
    
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "MenuBackground")
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        node.size = CGSize(width: size.width, height: size.height)
        node.zPosition = 1
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
        node.zPosition = 2
        node.text = "Oh dear! Marvin Mole's home is flooded and his food is all over the place.\n\nHelp him push his food back in the cupboards."
        node.numberOfLines = 0
        return node
    }()

    private lazy var startButton = {
        let node = TextButton(title: "Start", target: self, action: #selector(onStart))
        node.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.35)
        node.zPosition = 2
        return node
    }()
    
    @objc func onStart() {

        // load Sokoban map from resource bundle
        let resource = String(format: "%@%02d", mapCollection.title, mapNumber)
        let filePath = Bundle.main.url(forResource: resource, withExtension: "xsb")
        if let data = try? Data(contentsOf: filePath!) {
            
            // prepare game scene
            let map = Map.mapFromXsb(data: data)
            Scene.gameScene.load(map: map!)
            
            // prepare and go to map transistion scene
            Scene.mapIntroScene.title = String(format: "%@ %d", mapCollection.title, mapNumber)
            Scene.mapIntroScene.subtitle = map?.title
            transition(to: Scene.mapIntroScene)
        }
    }

    private lazy var mapCollectionButton = {
        let node = TextButton(title: mapCollection.title, target: self, action: #selector(onMapCollection))
        node.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.2)
        node.zPosition = 2
        return node
    }()
    
    @objc func onMapCollection() {
        var index = MapCollection.allCases.firstIndex(of: mapCollection)!
        index = (index + 1) % MapCollection.allCases.count
        mapCollection = MapCollection.allCases[index]
        mapCollectionButton.title = mapCollection.title
    }

    private lazy var mapNumberButton = {
        let node = TextButton(title: "\(mapNumber)", target: self, action: #selector(onMapNumber))
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.2)
        node.zPosition = 2
        return node
    }()
    
    @objc func onMapNumber() {
        mapNumber += 1
        if mapNumber > 3 {
            mapNumber = 1
        }
        mapNumberButton.title = "\(mapNumber)"
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
        for name in UIFont.familyNames {
            print(name)
            if let nameString = name as? String {
                print(UIFont.fontNames(forFamilyName: nameString))
            }
        }
        
    }
}


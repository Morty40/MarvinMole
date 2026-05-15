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
    private var mapNumber: Int = 0
    
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "MenuBackground")
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        node.size = CGSize(width: size.width, height: size.height)
        node.zPosition = 1
        return node
    }()
    
    private lazy var introText = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
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
        transition(to: Scene.gameScene)
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
        let node = TextButton(title: "\(mapNumber + 1)", target: self, action: #selector(onMapNumber))
        node.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.2)
        node.zPosition = 2
        return node
    }()
    
    @objc func onMapNumber() {
        mapNumber = (mapNumber + 1) % 10
        mapNumberButton.title = "\(mapNumber + 1)"
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        anchorPoint = .zero
        
        addChild(backgroundImage)
        addChild(introText)
        addChild(startButton)
        addChild(mapCollectionButton)
        addChild(mapNumberButton)
    }

    override func didMove(to view: SKView) {
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}


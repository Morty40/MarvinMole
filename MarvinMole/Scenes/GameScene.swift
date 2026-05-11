//
//  GameScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class GameObjectNode: SKSpriteNode {
    
    var mapPosition: (x: Int, y: Int) = (0, 0) {
        didSet {
            let w = parent?.frame.width ?? 0
            let h = parent?.frame.height ?? 0

            position = CGPoint(x: 32*(CGFloat(mapPosition.x)+0.5) - w/2,
                               y: h/2 - 32*(CGFloat(mapPosition.y)+0.5))
        }
    }
        
    init() {
        let texture = SKTexture(imageNamed: "Hero")
        super.init(texture: texture, color: .red, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Box: GameObjectNode {
}

class Hero: GameObjectNode {
    
}

private let smallXsb = """
    #####
    #   #
    #$  #
  ###  $##
  #  $ $ #
### # ## #   ######
#   # ## #####  ..#
# $  $          ..#
##### ### #@##  ..#
    #     #########
    #######
"""

class GameScene: Scene {
    
    private var map: Map = .empty
    private var boxes: [Box] = []
        
    enum Input {
        case left, up, right, down, undo
    }
    private var pendingInput: [Input] = []
    private var isMoving: Bool = false
    
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "GameBackground")
        node.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        node.size = CGSize(width: size.width, height: size.height)
        node.zPosition = 1
        return node
    }()

    private lazy var levelLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.position = CGPoint(x: frame.size.width * 0.86, y: frame.size.height * 0.73)
        node.fontColor = .black
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.zPosition = 2
        node.text = "Easy 1"
        return node
    }()

    private lazy var pushesLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.position = CGPoint(x: frame.size.width * 0.86, y: frame.size.height * 0.62)
        node.fontColor = .black
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.zPosition = 2
        return node
    }()

    private lazy var movesLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.position = CGPoint(x: frame.size.width * 0.86, y: frame.size.height * 0.50)
        node.fontColor = .black
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.zPosition = 2
        return node
    }()
    
    private lazy var staticTileMap = {
        let node = StaticTileMapNode()
        node.position = CGPoint(x: frame.size.width * 0.43, y: frame.size.height * 0.5)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.zPosition = 2
        return node
    }()

    private lazy var hero = {
        let node = Hero()
        node.position = .zero
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.zPosition = 3
        return node
    }()

    private lazy var undoButton = {
        let node = TextButton(title: "Undo", target: self, action: #selector(onUndo))
        node.position = CGPoint(x: frame.size.width * 0.8, y: frame.size.height * 0.1)
        node.zPosition = 2
        return node
    }()
    
    @objc func onUndo() {
        pendingInput.append(.undo)
    }

    private lazy var quitButton = {
        let node = TextButton(title: "Quit", target: self, action: #selector(onQuit))
        node.position = CGPoint(x: frame.size.width * 0.2, y: frame.size.height * 0.1)
        node.zPosition = 2
        return node
    }()
    
    @objc func onQuit() {
        transition(to: Scene.menuScene)
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        print("sceneDidLoad: GameScene")
        
        anchorPoint = .zero
        
        addChild(backgroundImage)
        addChild(levelLabel)
        addChild(pushesLabel)
        addChild(movesLabel)
        addChild(staticTileMap)
        addChild(undoButton)
        addChild(quitButton)

        staticTileMap.addChild(hero)
    }
    
    override func didMove(to view: SKView) {
        print("didMoveTo: GameScene")
        
        // remove any old gesture recognizers
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
        
        // add gesture recognizers for four way navigation
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeLeft),
                                     direction: .left))
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeUp),
                                     direction: .up))
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeRight),
                                     direction: .right))
        view.addGestureRecognizer(
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(onSwipeDown),
                                     direction: .down))
        
        // load map
        map = Map.mapFromXsb(string: smallXsb)!
        
        staticTileMap.draw(map: map)
        
        if let heroPosition = map.heroPosition {
            //hero.position = CGPoint(x: CGFloat(heroPosition.x) + 0.5, y: CGFloat(heroPosition.y) + 0.5)
            hero.mapPosition = heroPosition
            //addChild(hero!)
        }
        
        for boxPosition in map.boxPositions {
            let box = Box()
            box.mapPosition = boxPosition
            boxes.append(box)
        }
        
    }
    
    @objc func onSwipeLeft() {
        pendingInput.append(.left)
    }

    @objc func onSwipeUp() {
        pendingInput.append(.up)
    }

    @objc func onSwipeRight() {
        pendingInput.append(.right)
    }

    @objc func onSwipeDown() {
        pendingInput.append(.down)
    }

    override func update(_ currentTime: TimeInterval) {
        
        pushesLabel.text = "\(map.numberOfPushes)"
        movesLabel.text = "\(map.numberOfMoves)"

        processInput()
    }
    
    private func processInput() {
        if !isMoving, let nextInput = pendingInput.first {
            
            let legalMoves = map.legalMoves
            
            switch nextInput {
            case .left:
                if let move = legalMoves.first(where: \.isLeft) {
                    map.doNextMove(move)
                    hero.run(SKAction.moveBy(x: -32, y: 0, duration: 0.1)) {
                        self.isMoving = false
                    }
                }
            case .up:
                if let move = legalMoves.first(where: \.isUp) {
                    map.doNextMove(move)
                    hero.run(SKAction.moveBy(x: 0, y: 32, duration: 0.1)) {
                        self.isMoving = false
                    }
                }
            case .right:
                if let move = legalMoves.first(where: \.isRight) {
                    map.doNextMove(move)
                    hero.run(SKAction.moveBy(x: 32, y: 0, duration: 0.1)) {
                        self.isMoving = false
                    }
                }
            case .down:
                if let move = legalMoves.first(where: \.isDown) {
                    map.doNextMove(move)
                    hero.run(SKAction.moveBy(x: 0, y: -32, duration: 0.1)) {
                        self.isMoving = false
                    }
                }
            case .undo:
                map.undoLastMove()
            }
            
            pendingInput.removeFirst()
        }
    }
    
}

// sokoban tileset used for testing:
// https://dani-maccari.itch.io/sokoban-tileset

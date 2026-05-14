//
//  GameScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class GameObjectNode: SKSpriteNode {
    var id: Int = 0
    
    var mapPosition: (x: Int, y: Int) = (0, 0) {
        didSet {
            let w = parent?.frame.width ?? 0
            let h = parent?.frame.height ?? 0
            
            position = CGPoint(x: 32*(CGFloat(mapPosition.x)+0.5) - w/2,
                               y: h/2 - 32*(CGFloat(mapPosition.y)+0.5))
        }
    }
    
    init() {
        let texture = SKTexture(imageNamed: "HeroWalkLeft")
        super.init(texture: texture, color: .red, size: CGSize(width: 32, height: 32))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Box: GameObjectNode {
    
    override init() {
        super.init()
        self.texture = SKTexture(imageNamed: "Box")
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Hero: GameObjectNode {
    
    static let walkLeftTextures = SKTexture(imageNamed: "HeroWalkLeft").split(columns: 8)
    static let walkUpTextures = SKTexture(imageNamed: "HeroWalkUp").split(columns: 8)
    static let walkRightTextures = SKTexture(imageNamed: "HeroWalkRight").split(columns: 8)
    static let walkDownTextures = SKTexture(imageNamed: "HeroWalkDown").split(columns: 8)
    
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
    
    private lazy var tileMap = {
        let node = TileMap()
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
        
        anchorPoint = .zero
        
        addChild(backgroundImage)
        addChild(levelLabel)
        addChild(pushesLabel)
        addChild(movesLabel)
        addChild(tileMap)
        addChild(undoButton)
        addChild(quitButton)
        
        tileMap.addChild(hero)
    }
    
    override func didMove(to view: SKView) {
        
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
        
        tileMap.draw(map: map)
        
        if let heroPosition = map.heroPosition {
            hero.mapPosition = heroPosition
        }
        
        for b in map.objectsOfType(.box) {
            let box = Box()
            box.mapPosition = b.position
            box.id = b.id
            boxes.append(box)
            tileMap.addChild(box)
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

        for (obj, box) in zip(map.objectsOfType(.box), boxes) {
            box.mapPosition = obj.position
        }

    }
    
    private func processInput() {
        if !isMoving, let nextInput = pendingInput.first {
            
            let legalMoves = map.legalMoves
            
            switch nextInput {
            case .left:
                if let move = legalMoves.first(where: \.isLeft) {
                    map.doNextMove(move)
                    
                    let group = SKAction.group([
                        SKAction.animate(with: Hero.walkLeftTextures, timePerFrame: 0.05),
                        SKAction.moveBy(x: -32, y: 0, duration: 0.4)])
                    hero.run(group) {
                        self.isMoving = false
                    }
                }
            case .up:
                if let move = legalMoves.first(where: \.isUp) {
                    map.doNextMove(move)

                    let group = SKAction.group([
                        SKAction.animate(with: Hero.walkUpTextures, timePerFrame: 0.05),
                        SKAction.moveBy(x: 0, y: 32, duration: 0.4)])
                    hero.run(group) {
                        self.isMoving = false
                    }
                }
            case .right:
                if let move = legalMoves.first(where: \.isRight) {
                    map.doNextMove(move)
                    
                    let group = SKAction.group([
                        SKAction.animate(with: Hero.walkRightTextures, timePerFrame: 0.05),
                        SKAction.moveBy(x: 32, y: 0, duration: 0.4)])
                    hero.run(group) {
                        self.isMoving = false
                    }
                }
            case .down:
                if let move = legalMoves.first(where: \.isDown) {
                    map.doNextMove(move)

                    let group = SKAction.group([
                        SKAction.animate(with: Hero.walkDownTextures, timePerFrame: 0.05),
                        SKAction.moveBy(x: 0, y: -32, duration: 0.4)])
                    hero.run(group) {
                        self.isMoving = false
                    }
                }
            case .undo:
                map.undoLastMove()
                for (obj, box) in zip(map.objectsOfType(.box), boxes) {
                    box.mapPosition = obj.position
                }
                if let heroPosition = map.heroPosition {
                    hero.mapPosition = heroPosition
                }
            }
            
            pendingInput.removeFirst()
        }
    }
    
}

// sokoban tileset used for testing:
// https://dani-maccari.itch.io/sokoban-tileset

//
//  GameScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class GameObjectNode: SKSpriteNode {
    var id: Int = 0
    
    func setMapPosition(x: Int, y: Int, tileMap: TileMap) {
        let w = tileMap.frame.width / tileMap.xScale
        let h = tileMap.frame.height / tileMap.yScale
        
        position = CGPoint(x: 32*(CGFloat(x)+0.5) - w/2,
                           y: h/2 - 32*(CGFloat(y)+0.5))
    }
    
    init() {
        let texture = SKTexture(imageNamed: "HeroWalkLeft")
        super.init(texture: texture, color: .red, size: CGSize(width: 32, height: 32))
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameScene: Scene {
    
    private var map: Map = .empty
    
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
    
    private lazy var hero = {
        let node = Hero()
        node.position = .zero
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.zPosition = 3
        return node
    }()
    
    private lazy var boxContainer = {
        let node = SKNode()
        node.position = .zero
        node.zPosition = 3
        return node
    }()
    
    private lazy var tileMap = {
        let node = TileMap()
        node.position = CGPoint(x: frame.size.width * 0.43, y: frame.size.height * 0.53)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.zPosition = 2
        node.addChild(hero)
        node.addChild(boxContainer)
        
        node.xScale = 2
        node.yScale = 2
        
        return node
    }()
    
    private lazy var undoButton = {
        let node = TextButton(title: "Undo", target: self, action: #selector(onUndo))
        node.position = CGPoint(x: frame.size.width * 0.8, y: frame.size.height * 0.1)
        node.zPosition = 2
        return node
    }()
    
    @objc func onUndo() {
        register(input: .undo)
    }
    
    private lazy var quitButton = {
        let node = TextButton(title: "Quit", target: self, action: #selector(onQuit))
        node.position = CGPoint(x: frame.size.width * 0.2, y: frame.size.height * 0.1)
        node.zPosition = 2
        return node
    }()
    
    @objc func onQuit() {
        transition(to: Scene.quitScene)
    }
    
    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        anchorPoint = .zero
        
        addChild(backgroundImage)
        addChild(pushesLabel)
        addChild(movesLabel)
        addChild(tileMap)
        addChild(undoButton)
        addChild(quitButton)
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
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
    }
    
    func load(map: Map) {
        self.map = map
        
        tileMap.draw(map: map)
        boxContainer.removeAllChildren()
        for b in map.objectsOfType(.box) {
            let box = Box()
            box.id = b.id
            boxContainer.addChild(box)
        }
        updateObjectPositions()

        // scale small maps 2x
        let scale = map.size.width < 10 && map.size.height < 10 ? 2.0 : 1.0
        tileMap.xScale = scale
        tileMap.yScale = scale
    }
    
    @objc func onSwipeLeft() {
        register(input: .left)
    }
    
    @objc func onSwipeUp() {
        register(input: .up)
    }
    
    @objc func onSwipeRight() {
        register(input: .right)
    }
    
    @objc func onSwipeDown() {
        register(input: .down)
    }
    
    private func hudUpdate() {
        pushesLabel.text = "\(map.numberOfPushes)"
        movesLabel.text = "\(map.numberOfMoves)"
    }
    
    override func update(_ currentTime: TimeInterval) {
        hudUpdate()
        processInput()
    }
    
    /// Queue up input
    /// - Parameter input: User input
    private func register(input: Input) {
        if pendingInput.count < 3 {
            pendingInput.append(input)
        }
    }
    
    override func handleKey(_ key: UIKey) {
        switch key.keyCode {
        case .keyboardLeftArrow:
            register(input: .left)
        case .keyboardUpArrow:
            register(input: .up)
        case .keyboardRightArrow:
            register(input: .right)
        case .keyboardDownArrow:
            register(input: .down)
        case .keyboardDeleteOrBackspace:
            register(input: .undo)
        default:
            break
        }
    }
    
    private func animateMovedObjects(movedObjects: [Map.Object], move: Map.Move) {
        for obj in movedObjects {
            if obj.type == .hero {
                isMoving = true
                hero.run(hero.actionFor(move: move, distance: 32)) {
                    self.isMoving = false
                }
            }
            if obj.type == .box {
                for box in boxContainer.children {
                    if let box = box as? Box, box.id == obj.id {
                        if let action = box.actionFor(move: move, distance: 32) {
                            box.run(action)
                        }
                    }
                }
            }
        }
    }
    
    private func processInput() {
        if !isMoving, let nextInput = pendingInput.first {
            
            let legalMoves = map.legalMoves
            
            switch nextInput {
            case .left:
                if let move = legalMoves.first(where: \.isLeft) {
                    let movedObjects = map.doNextMove(move)
                    animateMovedObjects(movedObjects: movedObjects, move: move)
                }
                
            case .up:
                if let move = legalMoves.first(where: \.isUp) {
                    let movedObjects = map.doNextMove(move)
                    animateMovedObjects(movedObjects: movedObjects, move: move)
                }
                
            case .right:
                if let move = legalMoves.first(where: \.isRight) {
                    let movedObjects = map.doNextMove(move)
                    animateMovedObjects(movedObjects: movedObjects, move: move)
                }
                
            case .down:
                if let move = legalMoves.first(where: \.isDown) {
                    let movedObjects = map.doNextMove(move)
                    animateMovedObjects(movedObjects: movedObjects, move: move)
                }
                
            case .undo:
                map.undoLastMove()
                updateObjectPositions()
            }
            
            pendingInput.removeFirst()
        }
    }
    
    private func updateObjectPositions() {
        if let heroPosition = map.heroPosition {
            hero.setMapPosition(x: heroPosition.x,
                                y: heroPosition.y,
                                tileMap: tileMap)
        }

        for box in boxContainer.children {
            if let box = box as? Box {
                if let object = map.objectsOfType(.box).first(where: { $0.id == box.id }) {
                    box.setMapPosition(x: object.position.x,
                                       y: object.position.y,
                                       tileMap: tileMap)
                }
            }
        }
    }
    
}

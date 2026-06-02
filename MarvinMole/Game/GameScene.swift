//
//  GameScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

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
        node.fontName = "Rubik-Bold"
        node.fontSize = 35
        node.position = CGPoint(x: frame.size.width * 0.70, y: frame.size.height * 0.02)
        node.fontColor = .white
        node.horizontalAlignmentMode = .right
        node.verticalAlignmentMode = .baseline
        node.zPosition = 2
        return node
    }()
    
    private lazy var movesLabel = {
        let node = SKLabelNode()
        node.fontName = "Rubik-Bold"
        node.fontSize = 35
        node.position = CGPoint(x: frame.size.width * 0.48, y: frame.size.height * 0.02)
        node.fontColor = .white
        node.horizontalAlignmentMode = .right
        node.verticalAlignmentMode = .baseline
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
        
    private lazy var floorTileMap = {
        let node = TileMap(layer: .floors)
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.zPosition = 2
        node.addChild(hero)
        node.addChild(boxContainer)
        return node
    }()

    private lazy var shadowTileMap = {
        let node = TileMap(layer: .shadows)
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.zPosition = 3
        return node
    }()

    private lazy var wallTileMap = {
        let node = TileMap(layer: .walls)
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.zPosition = 10
        return node
    }()

    private lazy var quitButton = {
        let node = IconButton(imageName: "CloseIcon", target: self, action: #selector(onQuit))
        node.position = CGPoint(x: frame.size.width * 0.05, y: frame.size.height * 0.95)
        node.zPosition = 2
        return node
    }()
    
    @objc func onQuit() {
        transition(to: Scene.quitScene)
    }

    private lazy var undoButton = {
        let node = IconButton(imageName: "UndoIcon", target: self, action: #selector(onUndo))
        node.position = CGPoint(x: frame.size.width * 0.05, y: frame.size.height * 0.05)
        node.zPosition = 2
        return node
    }()
    
    @objc func onUndo() {
        register(input: .undo)
    }
        
    private lazy var leftButton = {
        let node = IconButton(imageName: "ArrowLeftIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width * 0.81, y: frame.size.height * 0.05)
        node.zPosition = 2
        return node
    }()

    private lazy var upButton = {
        let node = IconButton(imageName: "ArrowUpIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width * 0.88, y: frame.size.height * 0.15)
        node.zPosition = 2
        return node
    }()

    private lazy var rightButton = {
        let node = IconButton(imageName: "ArrowRightIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width * 0.95, y: frame.size.height * 0.05)
        node.zPosition = 2
        return node
    }()

    private lazy var downButton = {
        let node = IconButton(imageName: "ArrowDownIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width * 0.88, y: frame.size.height * 0.05)
        node.zPosition = 2
        return node
    }()

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(backgroundImage)
        addChild(pushesLabel)
        addChild(movesLabel)
        addChild(floorTileMap)
        addChild(shadowTileMap)
        addChild(wallTileMap)
        addChild(quitButton)
        addChild(undoButton)
        addChild(leftButton)
        addChild(upButton)
        addChild(rightButton)
        addChild(downButton)
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

        // clear tilemaps
        floorTileMap.clear()
        shadowTileMap.clear()
        wallTileMap.clear()

        // set size
        floorTileMap.size = map.size
        shadowTileMap.size = map.size
        wallTileMap.size = map.size

        // draw tilemaps
        floorTileMap.draw(map: map, rect: (x: 0, y: 0, width: map.size.width, height: map.size.height))
        shadowTileMap.draw(map: map, rect: (x: 0, y: 0, width: map.size.width, height: map.size.height))
        wallTileMap.draw(map: map, rect: (x: 0, y: 0, width: map.size.width, height: map.size.height))
        
        boxContainer.removeAllChildren()
        for b in map.objectsOfType(.box) {
            let box = Box()
            box.id = b.id
            boxContainer.addChild(box)
        }
        updateObjectPositions()

        // scale small maps 2x
        let scale = map.size.width < 10 && map.size.height < 10 ? 2.0 : 1.0
        floorTileMap.xScale = scale
        floorTileMap.yScale = scale
        shadowTileMap.xScale = scale
        shadowTileMap.yScale = scale
        wallTileMap.xScale = scale
        wallTileMap.yScale = scale
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
        
        hero.update(currentTime)
        
        if pendingInput.isEmpty, !isMoving {

            // read on-screen joystick input
            if leftButton.isPressed {
                register(input: .left)
            } else if upButton.isPressed {
                register(input: .up)
            } else if rightButton.isPressed {
                register(input: .right)
            } else if downButton.isPressed {
                register(input: .down)
            } else {

                // standing still, and no new input => idle
                hero.idle()
            }
        }
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
#if DEBUG
        case .keyboardF:
            floorTileMap.isHidden.toggle()
        case .keyboardS:
            shadowTileMap.isHidden.toggle()
        case .keyboardW:
            wallTileMap.isHidden.toggle()
#endif
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
                        if let action = box.actionFor(move: move,
                                                      toTile: map.tileAt(x: obj.position.x,
                                                                         y: obj.position.y),
                                                      distance: 32) {
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
                                tileMap: floorTileMap)
        }

        for box in boxContainer.children {
            if let box = box as? Box {
                if let object = map.objectsOfType(.box).first(where: { $0.id == box.id }) {
                    box.setMapPosition(x: object.position.x,
                                       y: object.position.y,
                                       tileMap: floorTileMap)
                }
            }
        }
    }
    
}

// TODO: Undo will move boxes back, but not update texture...
// TODO: Hero is starting on wrong texture

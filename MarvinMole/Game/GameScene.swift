//
//  GameScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class GameScene: Scene {
    
    let margin: CGFloat = 16
    let spacing: CGFloat = 12
    
    private var map: Map = .empty
    
    enum Input {
        case left, up, right, down, undo
    }
    private var pendingInput: [Input] = []
    
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
    
    private lazy var nextButton = {
        let node = TextButton(title: "Next >>", target: self, action: #selector(onNext))
        node.position = CGPoint(x: frame.size.width - margin - node.size.width/2,
                                y: frame.size.height - margin - node.size.height/2)
        return node
    }()
    
    @objc private func onNext() {

        // register solution
        let lurdString = Map.lurdStringFrom(moves: map.moves)
        let solution = MapManager.MapSolution(resourceName: MapManager.shared.selectedMap.resourceName,
                                              moves: lurdString)
        MapManager.shared.register(solution: solution)
        
        // advance to next
        MapManager.shared.incrementMapNumber()
        MapManager.shared.save()

        // load current map and transition
        Scene.loadingScene.loadCurrentMap()
        transition(to: Scene.loadingScene)
    }

    private lazy var pushesLabel = {
        let node = SKLabelNode()
        node.fontName = "Rubik-Bold"
        node.fontSize = 35
        node.position = CGPoint(x: frame.size.width * 0.70, y: frame.size.height * 0.02)
        node.fontColor = .white
        node.horizontalAlignmentMode = .right
        node.verticalAlignmentMode = .baseline
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
        return node
    }()
    
    private lazy var quitButton = {
        let node = IconButton(imageName: "CloseIcon", target: self, action: #selector(onQuit))
        node.position = CGPoint(x: margin + node.size.width/2,
                                y: frame.size.height - margin - node.size.height/2)
        return node
    }()
    
    @objc func onQuit() {
        transition(to: Scene.quitScene)
    }

    private lazy var undoButton = {
        let node = IconButton(imageName: "UndoIcon", target: self, action: #selector(onUndo))
        node.position = CGPoint(x: margin + node.size.width/2,
                                y: margin + node.size.height/2)
        return node
    }()
    
    @objc func onUndo() {
        register(input: .undo)
    }
        
    private lazy var leftButton = {
        let node = IconButton(imageName: "ArrowLeftIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width - margin - node.size.width - spacing - node.size.width - spacing - node.size.width/2,
                                y: margin + node.size.height/2)
        return node
    }()

    private lazy var upButton = {
        let node = IconButton(imageName: "ArrowUpIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width - margin - node.size.width - spacing - node.size.width/2,
                                y: margin + node.size.height + spacing + node.size.height/2)
        return node
    }()

    private lazy var rightButton = {
        let node = IconButton(imageName: "ArrowRightIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width - margin - node.size.width/2,
                                y: margin + node.size.height/2)
        return node
    }()

    private lazy var downButton = {
        let node = IconButton(imageName: "ArrowDownIcon", target: nil, action: nil)
        node.position = CGPoint(x: frame.size.width - margin - node.size.width - spacing - node.size.width/2,
                                y: margin + node.size.height/2)
        return node
    }()

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(backgroundImage)
        addChild(mapView)
        addChild(nextButton)
        addChild(pushesLabel)
        addChild(movesLabel)
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
        
        nextButton.isHidden = !map.isCompleted
    }
    
    func load(map: Map) {
        self.map = map
        mapView.update(with: map)
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
        super.update(currentTime)
        
        hudUpdate()

        mapView.hero.update(currentTime)
        
        if pendingInput.isEmpty, !mapView.hasActions() {

            nextButton.isHidden = !map.isCompleted

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
                mapView.hero.idle()
            }
        }
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
        case .keyboardEscape:
            onQuit()
#if DEBUG
        case .keyboardF:
            mapView.floorTileMap.isHidden.toggle()
        case .keyboardS:
            mapView.shadowTileMap.isHidden.toggle()
        case .keyboardW:
            mapView.wallTileMap.isHidden.toggle()
        case .keyboardO:
            let node = mapView.hero
            if let scene = node.scene {
                let globalPosition = node.parent!.convert(node.position, to: scene)
                let ft = FloatingText(text: "Oh dear!")
                ft.position = globalPosition
                ft.position.y += 20 * mapView.yScale
                addChild(ft)
                ft.runAnimation()
            }
#endif
        default:
            break
        }
    }
    
    private func processInput() {
        if !mapView.hasActions(), let nextInput = pendingInput.first {

            // no more legal moves once map is completed
            let legalMoves = map.isCompleted ? [] : map.legalMoves
            
            switch nextInput {
            case .left:
                if let move = legalMoves.first(where: \.isLeft) {
                    let movedObjects = map.makeMove(move)
                    mapView.animateMovedObjects(movedObjects: movedObjects, move: move, map: map)
                }
                
            case .up:
                if let move = legalMoves.first(where: \.isUp) {
                    let movedObjects = map.makeMove(move)
                    mapView.animateMovedObjects(movedObjects: movedObjects, move: move, map: map)
                }
                
            case .right:
                if let move = legalMoves.first(where: \.isRight) {
                    let movedObjects = map.makeMove(move)
                    mapView.animateMovedObjects(movedObjects: movedObjects, move: move, map: map)
                }
                
            case .down:
                if let move = legalMoves.first(where: \.isDown) {
                    let movedObjects = map.makeMove(move)
                    mapView.animateMovedObjects(movedObjects: movedObjects, move: move, map: map)
                }
                
            case .undo:
                // no more undo once map is completed
                if !map.isCompleted {
                    map.undoMove()
                    mapView.updateObjectPositions(map)
                }
            }

            pendingInput.removeFirst()
        }
    }
        
}

// TODO: Undo will move boxes back, but not update texture...

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
    
    // layers, back to front: map (with its grass), border, then HUD and GUI (zPosition 0)
        
    private lazy var mapView = {
        let node = MapView()
        node.playArea = MapView.borderPlayArea      // inside the flower and stone border
        node.zPosition = -20        // its sprites sit 1 above this
        return node
    }()

    /// Flower and stone border, framing the map
    private lazy var borderImage = {
        let node = SKSpriteNode(imageNamed: "GameBorder")
        node.position = center
        node.size = size
        node.zPosition = -10
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

    /// Number of moves, shown large in the grey stones under the top-right flowers
    private lazy var movesLabel = {
        let node = OutlinedLabel(fontName: "Rubik-Bold", fontSize: 90,
                                 horizontalAlignment: .right, verticalAlignment: .center)
        // right aligned with the right edge of the Up/Down buttons
        node.position = CGPoint(x: upButton.frame.maxX, y: frame.size.height * 0.575)
        return node
    }()
    
    private lazy var quitButton = {
        let node = IconButton(imageName: "CloseIcon", target: self, action: #selector(onQuit))
        node.position = CGPoint(x: margin + node.size.width/2,
                                y: frame.size.height - margin - node.size.height/2)
        return node
    }()
    
    /// The quit confirmation, while it is showing
    private weak var quitPopup: ModalPopup? = nil

    @objc func onQuit() {
        if ModalPopup.isShowing(in: self) {
            return
        }
        // wording and button order follow Apple's HIG for alerts: Cancel leading, action trailing
        let popup = ModalPopup(title: "Quit This Level?",
                               message: "Your progress on this level will be lost.",
                               buttons: [.init(title: "Cancel"),
                                         .init(title: "Quit") { [weak self] in
                                             self?.transition(to: Scene.menuScene)
                                         }])
        popup.show(in: self)
        quitPopup = popup
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
        
        addChild(mapView)
        addChild(borderImage)
        addChild(nextButton)
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
        // nothing until the first move
        let moves = map.numberOfMoves > 0 ? "\(map.numberOfMoves)" : ""
        if movesLabel.text != moves {
            movesLabel.text = moves
        }
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
        // no game input while a popup is showing
        if ModalPopup.isShowing(in: self) {
            return
        }
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
            // Escape opens the quit confirmation, or cancels it when it is showing
            if let quitPopup {
                quitPopup.dismiss()
            } else {
                onQuit()
            }
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
                    mapView.updateSpritePositions(map)
                }
            }

            pendingInput.removeFirst()
        }
    }
        
}

// TODO: Undo will move boxes back, but not update texture...

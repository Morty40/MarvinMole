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
        node.playArea = MapView.borderPlayArea(in: Scene.sceneSize)    // inside the flower and stone border
        node.zPosition = -20        // its sprites sit 1 above this
        return node
    }()

    /// Flower and stone border, framing the map
    private lazy var borderImage = {
        let node = backgroundSprite(imageNamed: "GameBorder")
        node.zPosition = -10
        return node
    }()
    
    /// Has the current map's completion started (the fanfare, then the popup)?
    private var isCompletionShown = false

    /// Has the fanfare finished, so the "level completed" popup can be shown?
    private var isFanfareFinished = false

    /// Short fanfares, one picked at random each time (Artwork/Music/compose_fanfare.py):
    /// "Food Away!", "Tidy Cupboards", "Call and Answer" and "Happy Dance"
    private let fanfares = (1 ... 4).map {
        SKAction.playSoundFileNamed("Fanfare\($0).m4a", waitForCompletion: true)
    }

    /// Level completed: save the solution, and play the fanfare while the cabinets close one by one;
    /// the popup follows once it has finished
    private func startCompletion() {
        isCompletionShown = true
        isFanfareFinished = false
        registerSolution()
        mapView.closeCabinets(map, within: 3.0)     // (the fanfares are 3.6 seconds)
        run(SKAction.sequence([fanfares.randomElement()!, SKAction.run { [weak self] in self?.isFanfareFinished = true }]),
            withKey: "fanfare")
    }

    /// Congratulate, and offer to go back to the menu or on to the next level
    private func showCompletion() {
        isFanfareFinished = false
        let popup = ModalPopup(title: "Level Complete",
                               message: "You did it! Marvin is happy!",
                               buttons: [.init(title: "Menu") { [weak self] in self?.onMenu() },
                                         .init(title: "Next") { [weak self] in self?.onNext() }])
        popup.show(in: self)
    }

    /// Register and save the solution of the completed map
    private func registerSolution() {
        let lurdString = Map.lurdStringFrom(moves: map.moves)
        let solution = MapManager.MapSolution(resourceName: MapManager.shared.selectedMap.resourceName,
                                              moves: lurdString)
        MapManager.shared.register(solution: solution)
        MapManager.shared.save()
    }

    private func onMenu() {
        transition(to: Scene.menuScene)
    }

    private func onNext() {
        // advance to next
        MapManager.shared.incrementMapNumber()
        MapManager.shared.save()

        // via the progress scene: SpriteKit can't transition from this scene to itself
        transition(to: Scene.progressScene)
    }

    /// Number of moves, shown large in the top-right corner
    private lazy var movesLabel = {
        let node = OutlinedLabel(fontName: "Rubik-Bold", fontSize: 90,
                                 horizontalAlignment: .right, verticalAlignment: .center)
        // the top of the digits the same margin from the corner as the buttons
        node.position = CGPoint(x: frame.size.width - margin, y: frame.size.height - margin - node.capHeight / 2)
        return node
    }()

    /// "move" / "moves", small, under the number of moves and right aligned with it
    private lazy var movesUnitLabel = {
        let node = OutlinedLabel(fontName: "Rubik-Bold", fontSize: 26,
                                 horizontalAlignment: .right, verticalAlignment: .top)
        node.position = CGPoint(x: movesLabel.position.x, y: movesLabel.position.y - movesLabel.capHeight / 2 - 12)
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
        node.longPressAction = #selector(onReset)
        node.position = CGPoint(x: margin + node.size.width/2,
                                y: margin + node.size.height/2)
        return node
    }()
    
    @objc func onUndo() {
        register(input: .undo)
    }

    /// Long press on Undo: offer to start the level over
    @objc func onReset() {
        if ModalPopup.isShowing(in: self) || map.isCompleted {
            return
        }
        // wording and button order follow Apple's HIG for alerts: Cancel leading, action trailing
        let popup = ModalPopup(title: "Reset This Level?",
                               message: "All your moves on this level will be undone.",
                               buttons: [.init(title: "Cancel"),
                                         .init(title: "Reset") { [weak self] in self?.resetMap() }])
        popup.show(in: self)
    }

    /// Starts the current level over, from its starting position
    private func resetMap() {
        guard let map = Map.mapFromBundle(resource: MapManager.shared.selectedMap.resourceName) else {
            return
        }
        load(map: map)
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
        addChild(movesLabel)
        addChild(movesUnitLabel)
        addChild(quitButton)
        addChild(undoButton)
        addChild(leftButton)
        addChild(upButton)
        addChild(rightButton)
        addChild(downButton)
    }
    
    /// Swipes for four way navigation; on the view only while this scene is showing, so they don't
    /// delay or cancel touches in the other scenes (e.g. the menu buttons), or queue moves from there
    private lazy var swipeRecognizers: [UISwipeGestureRecognizer] = [
        (#selector(onSwipeLeft), .left), (#selector(onSwipeUp), .up),
        (#selector(onSwipeRight), .right), (#selector(onSwipeDown), .down),
    ].map { action, direction in
        let recognizer = UISwipeGestureRecognizer(target: self, action: action)
        recognizer.direction = direction
        return recognizer
    }

    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        swipeRecognizers.forEach { view.addGestureRecognizer($0) }
    }

    override func willMove(from view: SKView) {
        swipeRecognizers.forEach { view.removeGestureRecognizer($0) }
    }
    
    /// Starts the selected map: loads it, and presents this scene from `scene` with a transition
    /// that shows the level title while the screen is covered, uncovering straight into the game.
    /// `scene` must be another scene: SpriteKit can't transition from a scene to itself.
    func startCurrentMap(from scene: SKScene) {
        let selected = MapManager.shared.selectedMap
        guard let map = Map.mapFromBundle(resource: selected.resourceName) else {
            return
        }
        load(map: map)
        let transition = SKTransition.chessboard(snakeDuration: 0.6, waitDuration: 1.6, from: scene,
                                                 title: "\(selected.collection.title) \(selected.number)",
                                                 subtitle: map.title?.trimmingCharacters(in: .whitespaces))
        scene.view?.presentScene(self, transition: transition)
    }

    func load(map: Map) {
        self.map = map
        isCompletionShown = false
        isFanfareFinished = false
        removeAction(forKey: "fanfare")     // the previous level's, if it was left during the fanfare
        pendingInput.removeAll()        // moves queued for the previous map
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
        let count = map.numberOfMoves
        let moves = count > 0 ? "\(count)" : ""
        if movesLabel.text != moves {
            movesLabel.text = moves
            movesUnitLabel.text = count == 0 ? "" : count == 1 ? "move" : "moves"
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        hudUpdate()

        mapView.hero.update(currentTime)
        
        if pendingInput.isEmpty, !mapView.hasActions() {

            // level completed (and the last move has finished animating): fanfare, then the popup
            // (if another popup is showing, e.g. the quit question, it waits until that is closed)
            if map.isCompleted, !isCompletionShown {
                startCompletion()
            } else if isFanfareFinished, !ModalPopup.isShowing(in: self) {
                showCompletion()
            }

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
        case .keyboardG:
            mapView.grassTileMap.isHidden.toggle()
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

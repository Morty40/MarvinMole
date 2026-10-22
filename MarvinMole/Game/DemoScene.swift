//
//  DemoScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class DemoScene: Scene {
    
    private var startTime: TimeInterval = 0.0

    /// When the map was completed (its last push animated), zero until then
    private var completedTime: TimeInterval = 0.0

    /// Set once going back to the menu, so it only happens once
    private var isClosing = false

    /// Seconds the demo lasts at most, and seconds the completed map stays on screen
    private let maxDuration: TimeInterval = 30.0
    private let completedDuration: TimeInterval = 3.0
    private var map: Map = .empty
    private var moves: [Map.Move] = []

    /// Before solving the level, Marvin idles for a moment, says something, and waits a little longer
    private let pauseBeforeSaying: TimeInterval = 0.5
    private let waitAfterSaying: ClosedRange<TimeInterval> = 1 ... 2

    /// Set while Marvin idles before he starts solving the level
    private var isStarting = true

    /// What Marvin says when he sees his flooded burrow, and his food all over the floor
    private let startSayings = ["What a mess!", "Let's get this cleaned up!", "Oh dear!",
                                "Food everywhere!", "Who left the tap on?",
                                "Soggy snacks again!", "Time to tidy up.", "Not again!"]
    
    // layers, back to front: map (with its grass), border (same as GameScene)
    
    private lazy var mapView = {
        let node = MapView()
        node.playArea = MapView.borderPlayArea(in: Scene.sceneSize)    // inside the flower and stone border
        node.zPosition = -20                        // its sprites sit 1 above this
        return node
    }()

    /// Flower and stone border, framing the map
    private lazy var borderImage = {
        let node = backgroundSprite(imageNamed: "GameBorder")
        node.zPosition = -10
        return node
    }()
    
    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(mapView)
        addChild(borderImage)
    }

    /// The demo map: a random level from any collection, ready to replay its solution from the start.
    /// Call before each demo, as the replay uses up the moves.
    func prepare() -> Map {
        let levels = MapManager.MapCollection.allCases.flatMap { collection in
            (1 ... collection.count).map { String(format: collection.resourceName, $0) }
        }
        // a level with a solution (all levels have one, but don't rely on it)
        for resource in levels.shuffled() {
            if let map = Map.mapFromBundle(resource: resource), let solution = map.solution {
                self.map = map
                self.moves = Map.movesFrom(lurd: solution)
                mapView.update(with: map)
                return map
            }
        }
        return map
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        startTime = 0.0
        completedTime = 0.0
        isClosing = false

        // as actions: they are paused while a transition into this scene runs, so this only starts
        // once the scene is showing
        isStarting = true
        removeAction(forKey: "start")
        run(SKAction.sequence([SKAction.wait(forDuration: pauseBeforeSaying),
                               SKAction.run { [weak self] in self?.say(from: self?.startSayings ?? []) },
                               SKAction.wait(forDuration: .random(in: waitAfterSaying)),
                               SKAction.run { [weak self] in self?.isStarting = false }]),
            withKey: "start")
    }

    /// Marvin says one of `list`, floating up above him
    private func say(from list: [String]) {
        guard let saying = list.randomElement() else {
            return
        }
        let hero = mapView.hero
        let text = FloatingText(text: saying)
        text.position = hero.parent!.convert(hero.position, to: self)
        text.position.y += 20 * mapView.yScale
        addChild(text)
        text.runAnimation()
    }
    
    override func handleKey(_ key: UIKey) {
        // any key goes back to the menu
        close()
    }

    private func close() {
        if !isClosing {
            isClosing = true
            transition(to: Scene.menuScene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        mapView.hero.update(currentTime)
        
        if !mapView.hasActions() {
            
            if !isStarting, let move = moves.first {
                let movedObjects = map.makeMove(move)
                mapView.animateMovedObjects(movedObjects: movedObjects, move: move, map: map)
                moves.removeFirst()
                
            } else {
                mapView.hero.idle()
            }
        }
        
        // back to the menu a moment after the map is completed, or after some time in any case
        if startTime.isZero {
            startTime = currentTime
        }
        if completedTime.isZero, map.isCompleted, !mapView.hasActions() {
            completedTime = currentTime
        }
        if currentTime - startTime > maxDuration
            || (!completedTime.isZero && currentTime - completedTime > completedDuration) {
            close()
        }
        
    }

}

// TODO: add tap gesture recognizer, that transitions back to the menu. Check menu buttons are still working (bug?)

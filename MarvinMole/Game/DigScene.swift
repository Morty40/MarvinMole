//
//  DigScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Marvin Mole shows how he digs his tunnels. Shown by the menu now and then (taking turns with the demo
/// and the credits). He starts in a single dug out spot, surrounded by walls, and digs out the floor of a
/// random level (with its cupboards, without food), the view zooming out as the tunnels grow.
/// Back to the menu a moment after the level is dug out, after some time in any case, or on a tap or key.
class DigScene: Scene {

    private var startTime: TimeInterval = 0.0

    /// When the last tile was dug out, zero until then
    private var finishedTime: TimeInterval = 0.0

    /// Set once going back to the menu, so it only happens once
    private var isClosing = false

    /// Seconds the scene lasts at most, and seconds the dug out level stays on screen
    private let maxDuration: TimeInterval = 30.0
    private let finishedDuration: TimeInterval = 3.0

    /// Seconds per step (a bit quicker than walking in the game)
    private let stepDuration: TimeInterval = 0.3

    /// Seconds Marvin waits in his starting spot (one dug out cell, walls all around) before digging
    private let startDelay: TimeInterval = 1.5

    /// The map being dug: the size of the level, void (grass) where nothing has been dug yet
    private var map: Map = .empty

    /// Marvin's steps, in order: digging into new ground, and walking back through his tunnels
    private var steps: [Map.Move] = []

    /// The level's goals: dug out, they show cupboards
    private var goals = Set<Cell>()

    /// A rectangle of cells (tile coordinates)
    private struct Area: Equatable {
        var minX, minY, maxX, maxY: Int
    }

    /// The part of the map in view, to zoom out as the tunnels grow
    private var viewArea: Area? = nil

    // layers, back to front: map (with its grass), border (same as GameScene)

    private lazy var mapView = {
        let node = MapView()
        node.playArea = MapView.borderPlayArea      // inside the flower and stone border
        node.coversZoom = true                      // the view zooms in on the tunnels
        node.zPosition = -20                        // its sprites sit 1 above this
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

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()

        addChild(mapView)
        addChild(borderImage)
    }

    /// Picks a random level and plans the digging. Call before each time the scene is shown.
    func prepare() {
        let levels = MapManager.MapCollection.allCases.flatMap { collection in
            (1 ... collection.count).map { String(format: collection.resourceName, $0) }
        }
        guard let resource = levels.randomElement(),
              let level = Map.mapFromBundle(resource: resource),
              let start = level.heroPosition else {
            return
        }

        // the floor to dig out: the level's floor, and its goals, which show up as cupboards when dug out
        var floor = Set<Cell>()
        goals = []
        for y in 0 ..< level.size.height {
            for x in 0 ..< level.size.width where level.tileAt(x: x, y: y).isFloor {
                floor.insert(Cell(x: x, y: y))
                if level.tileAt(x: x, y: y) == .floorGoal {
                    goals.insert(Cell(x: x, y: y))
                }
            }
        }
        steps = Self.plan(floor: floor, from: Cell(x: start.x, y: start.y))

        // the map to dig in: nothing dug yet, except where Marvin stands
        let tiles = Array(repeating: Array(repeating: Map.Tile.void, count: level.size.width),
                          count: level.size.height)
        map = Map(title: level.title, tiles: tiles,
                  objects: [Map.Object(position: start, type: .hero, id: 0)])
        dig(Cell(x: start.x, y: start.y))

        mapView.hero.removeAllActions()             // a step left over from the last time
        mapView.update(with: map)
        viewArea = nil
        updateView(animated: false)
    }

    /// A cell of the map
    private struct Cell: Hashable {
        let x: Int, y: Int
        func moved(_ move: Map.Move) -> Cell {
            switch move {
            case .walkLeft, .pushLeft: Cell(x: x - 1, y: y)
            case .walkUp, .pushUp: Cell(x: x, y: y - 1)
            case .walkRight, .pushRight: Cell(x: x + 1, y: y)
            case .walkDown, .pushDown: Cell(x: x, y: y + 1)
            }
        }
    }

    /// Marvin's steps to dig out all of `floor`: a depth first search from `start`, so he digs a tunnel as
    /// far as it goes, then walks back to dig the next one. He mostly keeps going in the same direction,
    /// which makes long, straight tunnels. Steps into new ground dig; the last step digs the last cell.
    private static func plan(floor: Set<Cell>, from start: Cell) -> [Map.Move] {
        let directions: [Map.Move] = [.walkLeft, .walkUp, .walkRight, .walkDown]
        let opposite: [Map.Move: Map.Move] = [.walkLeft: .walkRight, .walkRight: .walkLeft,
                                              .walkUp: .walkDown, .walkDown: .walkUp]
        var dug: Set<Cell> = [start]
        var steps: [Map.Move] = []
        var stack: [(cell: Cell, cameBy: Map.Move?)] = [(start, nil)]

        while let (cell, cameBy) = stack.last, dug.count < floor.count {
            // the next undug neighbour, preferring to keep going straight
            var order = directions.shuffled()
            if let cameBy, Double.random(in: 0 ..< 1) < 0.7, let i = order.firstIndex(of: cameBy) {
                order.swapAt(0, i)
            }
            if let move = order.first(where: { floor.contains(cell.moved($0)) && !dug.contains(cell.moved($0)) }) {
                let next = cell.moved(move)
                dug.insert(next)
                steps.append(move)
                stack.append((next, move))
            } else {
                // a dead end: walk back the way he came
                stack.removeLast()
                if let cameBy, !stack.isEmpty {
                    steps.append(opposite[cameBy]!)
                }
            }
        }
        return steps
    }

    /// Digs out a cell: it becomes floor (or a cupboard), and everything around it that isn't dug yet becomes wall
    private func dig(_ cell: Cell) {
        map.setTile(goals.contains(cell) ? .floorGoal : .floor, x: cell.x, y: cell.y)
        for dy in -1 ... 1 {
            for dx in -1 ... 1 where map.tileAt(x: cell.x + dx, y: cell.y + dy) == .void {
                map.setTile(.wall, x: cell.x + dx, y: cell.y + dy)
            }
        }
    }

    /// Zooms and moves the view to show all of the dug out tunnels and their walls,
    /// as large as fits in the play area (at most 3x, the same as a level)
    private func updateView(animated: Bool) {
        var area: Area? = nil
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width where map.tileAt(x: x, y: y) != .void {
                area = area.map { Area(minX: min($0.minX, x), minY: min($0.minY, y),
                                       maxX: max($0.maxX, x), maxY: max($0.maxY, y)) }
                    ?? Area(minX: x, minY: y, maxX: x, maxY: y)
            }
        }
        guard let area, area != viewArea else {
            return
        }
        viewArea = area

        let playArea = mapView.playArea
        let width = CGFloat(area.maxX - area.minX + 1) * 32
        let height = CGFloat(area.maxY - area.minY + 1) * 32
        let scale = min(3.0, playArea.width / width, playArea.height / height)

        // centre of the area, in the map view's coordinates (the tile maps are centred on it, y up)
        let mapWidth = CGFloat(map.size.width) * 32, mapHeight = CGFloat(map.size.height) * 32
        let centre = CGPoint(x: CGFloat(area.minX + area.maxX + 1) * 16 - mapWidth / 2,
                             y: mapHeight / 2 - CGFloat(area.minY + area.maxY + 1) * 16)
        let position = CGPoint(x: playArea.midX - centre.x * scale, y: playArea.midY - centre.y * scale)

        mapView.removeAction(forKey: "view")
        if animated {
            let action = SKAction.group([SKAction.scale(to: scale, duration: 0.8),
                                         SKAction.move(to: position, duration: 0.8)])
            action.timingMode = .easeInEaseOut
            mapView.run(action, withKey: "view")
        } else {
            mapView.setScale(scale)
            mapView.position = position
        }
    }

    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        startTime = 0.0
        finishedTime = 0.0
        isClosing = false
    }

    override func handleKey(_ key: UIKey) {
        // any key goes back to the menu
        close()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // a tap anywhere goes back to the menu
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

        let hero = mapView.hero
        hero.update(currentTime)

        if startTime.isZero {
            startTime = currentTime
        }
        let isDigging = currentTime - startTime > startDelay

        if !hero.hasActions() {
            if isDigging, let move = steps.first, let position = map.heroPosition {
                steps.removeFirst()
                let next = Cell(x: position.x, y: position.y).moved(move)
                if !map.tileAt(x: next.x, y: next.y).isFloor {
                    // new ground: dig it out as Marvin moves in
                    dig(next)
                    mapView.redrawTiles(map)
                    updateView(animated: true)
                }
                _ = map.makeMove(move)
                hero.run(hero.actionFor(move: move, distance: 32, duration: stepDuration))
            } else {
                hero.idle()
            }
        }

        // back to the menu a moment after the level is dug out, or after some time in any case
        if finishedTime.isZero, steps.isEmpty, !hero.hasActions() {
            finishedTime = currentTime
        }
        if currentTime - startTime > maxDuration
            || (!finishedTime.isZero && currentTime - finishedTime > finishedDuration) {
            close()
        }
    }
}

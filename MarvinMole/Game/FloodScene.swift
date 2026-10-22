//
//  FloodScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class FloodScene: Scene {
    
    private var map: Map = .empty
    
    // layers, back to front: map (with its grass), border (same as GameScene)
    
    private lazy var mapView = {
        let node = MapView()
        node.playArea = MapView.borderPlayArea(in: Scene.sceneSize)    // inside the flower and stone border
        node.zPosition = -20        // its sprites sit 1 above this
        // the food is under the water, and the water under the walls (the water is also drawn on the
        // walls next to it, so the walls' rounded corners show water)
        node.waterTileMap.zPosition = 1.5
        node.wallTileMap.zPosition = 2
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
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        // a sequence left over from the last time (e.g. skipped with a key) must not run along
        removeAction(forKey: "flooding")
        run(floodingSequence(), withKey: "flooding")
    }

    // timing, in seconds
    private let pause: TimeInterval = 0.6                // between the steps
    private let floodStepDuration: TimeInterval = 0.05   // per step of the water spreading
    private let riseDuration: TimeInterval = 1.0
    private let drainDuration: TimeInterval = 1.0

    /// The water is see-through while it spreads, and opaque once it has risen
    private let spreadingAlpha: CGFloat = 0.5

    /// The flooding, step by step:
    /// 1. the empty map (floor, shadows, walls, cupboards; no food, no Marvin)
    /// 2. water spreads from a random floor tile, breadth first, semi transparent
    /// 3. the water rises: it becomes opaque
    /// 4. the food appears where it belongs, and Marvin where he starts, under the water
    /// 5. the water drops: it fades out
    /// 6. on to the next scene (the demo), which shows the same map
    private func floodingSequence() -> SKAction {
        let water = mapView.waterTileMap
        let floor = floorCells()
        guard let start = floor.randomElement() else {
            return SKAction.run { [weak self] in self?.finish() }
        }
        let distance = distances(from: start, in: floor)
        let maxDistance = distance.values.max() ?? 0

        var steps: [SKAction] = []

        // 1. the empty map, without water
        steps.append(SKAction.run { [weak self] in
            guard let self else { return }
            water.clear()
            water.alpha = self.spreadingAlpha
            self.mapView.boxContainer.isHidden = true
            self.mapView.hero.isHidden = true
        })
        steps.append(SKAction.wait(forDuration: pause))

        // 2. the water spreads, one step of the breadth first search at a time
        for d in 0 ... maxDistance + 1 {
            steps.append(SKAction.run { [weak self] in
                guard let self else { return }
                water.draw(map: self.map, isWater: { distance[Cell(x: $0, y: $1)].map { $0 < d } ?? false })
            })
            steps.append(SKAction.wait(forDuration: floodStepDuration))
        }
        steps.append(SKAction.wait(forDuration: pause))

        // 3. the water rises
        steps.append(SKAction.run { water.run(SKAction.fadeAlpha(to: 1.0, duration: self.riseDuration)) })
        steps.append(SKAction.wait(forDuration: riseDuration + pause))

        // 4. the food where it belongs, and Marvin, under the (opaque) water
        steps.append(SKAction.run { [weak self] in
            guard let self else { return }
            self.mapView.updateSpritePositions(self.map)
            self.mapView.boxContainer.isHidden = false
            self.mapView.hero.isHidden = false
        })
        steps.append(SKAction.wait(forDuration: pause))

        // 5. the water drops
        steps.append(SKAction.run { water.run(SKAction.fadeAlpha(to: 0, duration: self.drainDuration)) })
        steps.append(SKAction.wait(forDuration: drainDuration + pause))

        // 6. on to the next scene
        steps.append(SKAction.run { [weak self] in self?.finish() })
        return SKAction.sequence(steps)
    }

    /// A cell of the map
    private struct Cell: Hashable {
        let x: Int, y: Int
        var neighbours: [Cell] {
            [Cell(x: x - 1, y: y), Cell(x: x + 1, y: y), Cell(x: x, y: y - 1), Cell(x: x, y: y + 1)]
        }
    }

    private func floorCells() -> Set<Cell> {
        var cells = Set<Cell>()
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width where map.tileAt(x: x, y: y).isFloor {
                cells.insert(Cell(x: x, y: y))
            }
        }
        return cells
    }

    /// Breadth first: the number of steps from `start` to every floor cell reachable from it
    private func distances(from start: Cell, in floor: Set<Cell>) -> [Cell: Int] {
        var distance = [start: 0]
        var queue = [start]
        var i = 0
        while i < queue.count {
            let cell = queue[i]; i += 1
            for n in cell.neighbours where floor.contains(n) && distance[n] == nil {
                distance[n] = distance[cell]! + 1
                queue.append(n)
            }
        }
        return distance
    }

    private func finish() {
        removeAction(forKey: "flooding")
        transition(to: nextScene, animated: false)
    }

    /// The scene that follows the flooding (it shows the same map)
    private var nextScene: SKScene = Scene.demoScene

    func load(map: Map, then nextScene: SKScene) {
        self.map = map
        self.nextScene = nextScene
        mapView.update(with: map)
        mapView.hero.isHidden = true
        mapView.boxContainer.isHidden = true
    }
    
    override func handleKey(_ key: UIKey) {
        // any key skips to the next scene
        finish()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        mapView.hero.update(currentTime)
        if !mapView.hero.isHidden {
            mapView.hero.idle()     // (the idle animation also gives him his picture)
        }
    }

}

// TODO: add tap gesture recognizer, that transitions back to the menu. Check menu buttons are still working (bug?)

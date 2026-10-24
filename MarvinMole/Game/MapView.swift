//
//  MapView.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MapView: SKNode {
        
    lazy var floorTileMap = {
        let node = FloorTileMap()
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50) // TODO ?
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()

    lazy var shadowTileMap = {
        let node = ShadowTileMap()
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()
    
    lazy var hero = { // TODO: private
        let node = Hero(id: 0) // TODO: id is important?
        node.position = .zero
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()
    
    lazy var boxContainer = {
        let node = SKNode()
        node.position = .zero
        return node
    }()

    lazy var waterTileMap = {
        let node = WaterTileMap()
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()

    lazy var wallTileMap = {
        let node = WallTileMap()
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()
    
    /// Grass covering the whole scene, behind the map, on the same tile grid
    lazy var grassTileMap = {
        let node = GrassTileMap()
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()

    /// Size of the scene the grass must cover
    var sceneSize = Scene.sceneSize

    /// Set when the view will zoom in on parts of the map (larger scale, moved position):
    /// the grass then covers the scene for any part of the map
    var coversZoom = false

    override init() {
        super.init()
        
        addChild(grassTileMap)
        addChild(floorTileMap)
        addChild(shadowTileMap)
        addChild(hero)
        addChild(boxContainer)
        addChild(waterTileMap)
        addChild(wallTileMap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Area of the scene the map is fitted into (scene coordinates)
    var playArea = CGRect(origin: .zero, size: Scene.sceneSize).insetBy(dx: 125, dy: 125)

    /// The open area inside the flower and stone border (GameBorder), measured from the image as drawn
    /// at 1024 x 768 points: 8 points in from the border's edge, and clear of the buttons and the move
    /// counter in the corners. On the right it reaches a little past the pink flowers in the top-right
    /// corner: a map there may touch, or slightly overlap, them
    private static let borderOpening = CGRect(x: 93, y: 153, width: 697, height: 486)

    /// The border's opening in a scene of `sceneSize`: the border covers the scene (scaled evenly and
    /// centred, see `Scene.backgroundSprite`), and the opening scales and moves with it
    static func borderPlayArea(in sceneSize: CGSize) -> CGRect {
        let designSize = CGSize(width: 1024, height: 768)
        let drawn = Scene.coverSize(of: designSize, in: sceneSize)
        let scale = drawn.width / designSize.width
        let origin = CGPoint(x: (sceneSize.width - drawn.width) / 2, y: (sceneSize.height - drawn.height) / 2)
        return CGRect(x: origin.x + borderOpening.minX * scale, y: origin.y + borderOpening.minY * scale,
                      width: borderOpening.width * scale, height: borderOpening.height * scale)
    }

    func update(with map: Map) {
        // stop a move that may still be animating from the previous map (when a scene was left in the
        // middle of a move): moves animate relative to the hero's position, so the rest of that move
        // would push the hero off his tile once the scene runs again
        hero.removeAllActions()
        hero.lastTime = 0
        removeAction(forKey: "cabinets")    // cabinets still closing on the previous map

        waterTileMap.clear()
        waterTileMap.size = map.size
        // waterTileMap is only used for the flooding sequence
        redrawTiles(map)
        
        // one type of food per level, chosen at random, but always the same for the same level
        var mixed = seed(for: map) &* 0x9E3779B97F4A7C15
        mixed ^= mixed >> 31
        let boxType = Int(mixed % UInt64(Box.boxTextures.count))

        boxContainer.removeAllChildren()
        for b in map.objectsOfType(.box) {
            let box = Box(id: b.id, type: boxType)
            boxContainer.addChild(box)
        }
        updateSpritePositions(map)
        
        // map scale and position: as large as fits in the play area (at most 3x), centred in it
        let scaleWidth = playArea.width / CGFloat(map.size.width * 32)
        let scaleHeight = playArea.height / CGFloat(map.size.height * 32)
        let scale = min(3.0, scaleWidth, scaleHeight)
        xScale = scale
        yScale = scale
        position = CGPoint(x: playArea.midX, y: playArea.midY)

        // grass: enough tiles to cover the whole scene at this scale, centred on the map like the other
        // tilemaps; an even difference in tile count keeps the grass on the same grid as the map
        func tiles(_ mapTiles: Int, _ centre: CGFloat, _ extent: CGFloat) -> Int {
            // (when the view zooms in on parts of the map, the grass must reach further)
            let half = (coversZoom ? extent : max(centre, extent - centre)) / scale
            var n = Int((2 * half / 32).rounded(.up)) + 2
            if (n - mapTiles) % 2 != 0 { n += 1 }
            return max(n, mapTiles)
        }
        grassTileMap.clear()
        grassTileMap.size = (tiles(map.size.width, position.x, sceneSize.width),
                             tiles(map.size.height, position.y, sceneSize.height))
        grassTileMap.draw(seed: seed(for: map))
    }
    
    /// Redraws the floor, shadow and wall tile maps from the map's tiles, e.g. after the map has changed;
    /// the sprites, scale and position stay as they are
    func redrawTiles(_ map: Map) {
        floorTileMap.clear()
        shadowTileMap.clear()
        wallTileMap.clear()

        floorTileMap.size = map.size
        shadowTileMap.size = map.size
        wallTileMap.size = map.size

        floorTileMap.draw(map: map, seed: seed(for: map))
        shadowTileMap.draw(map: map)
        wallTileMap.draw(map: map)
    }

    /// A stable seed per level, for its random floor, grass and food
    /// (String.hashValue changes between launches, so it can't be used)
    private func seed(for map: Map) -> UInt64 {
        (map.title ?? "").utf8.reduce(UInt64(map.size.width * 1000 + map.size.height)) { $0 &* 31 &+ UInt64($1) }
    }

    func updateSpritePositions(_ map: Map) {
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
                    // a crate on a cabinet tile, food elsewhere (at the start, and after an undo)
                    box.updateTexture(on: map.tileAt(x: object.position.x, y: object.position.y))
                }
            }
        }
    }

    /// Closes the cabinets with a crate on them, one at a time, top to bottom and left to right:
    /// each crate disappears into its cabinet with a puff of smoke, and the cabinet closes.
    /// - Parameter duration: The time to spread them over (with at most half a second between them)
    /// - Returns: How long it takes, in seconds
    @discardableResult
    func closeCabinets(_ map: Map, within duration: TimeInterval) -> TimeInterval {
        let crates = map.objectsOfType(.box)
            .filter { map.tileAt(x: $0.position.x, y: $0.position.y) == .floorGoal }
            .sorted { ($0.position.y, $0.position.x) < ($1.position.y, $1.position.x) }
        let interval = crates.count > 1
            ? min(0.5, max(0, duration - Box.disappearDuration) / Double(crates.count - 1)) : 0
        var steps: [SKAction] = []
        for (i, crate) in crates.enumerated() {
            guard let box = boxContainer.children.first(where: { ($0 as? Box)?.id == crate.id }) as? Box else {
                continue
            }
            if i > 0 {
                steps.append(SKAction.wait(forDuration: interval))
            }
            steps.append(SKAction.run { [weak self] in
                box.disappearIntoCabinet()
                self?.floorTileMap.setCabinet(open: false, x: crate.position.x, y: crate.position.y)
            })
        }
        run(SKAction.sequence(steps), withKey: "cabinets")
        return Double(max(crates.count - 1, 0)) * interval + Box.disappearDuration
    }

    override func hasActions() -> Bool {
        return hero.hasActions() // || boxContainer.children.contains(where: { $0.hasActions() })
    }
    
    func animateMovedObjects(movedObjects: [Map.Object], move: Map.Move, map: Map) {
        for obj in movedObjects {
            if obj.type == .hero {
                hero.run(hero.actionFor(move: move, distance: 32))
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
    
}

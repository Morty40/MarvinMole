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
    var sceneSize = CGSize(width: 1024, height: 768)

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
    var playArea = CGRect(x: 125, y: 125, width: 1024 - 250, height: 768 - 250)

    /// The open area inside the flower and stone border (GameBorder), measured from the image:
    /// the largest rectangle that fits, 8 points in from the border's edge,
    /// and clear of the buttons and the move counter in the corners
    static let borderPlayArea = CGRect(x: 93, y: 153, width: 660, height: 486)

    func update(with map: Map) {
        waterTileMap.clear()
        waterTileMap.size = map.size
        // waterTileMap is only used for the flooding sequence
        redrawTiles(map)
        
        boxContainer.removeAllChildren()
        for b in map.objectsOfType(.box) {
            let box = Box(id: b.id)
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

    /// A stable seed per level, for its random floor and grass
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
                    // a crate on a cupboard tile, food elsewhere (at the start, and after an undo)
                    box.updateTexture(on: map.tileAt(x: object.position.x, y: object.position.y))
                }
            }
        }
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

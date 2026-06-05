//
//  MapView.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MapView: SKNode {
        
    lazy var floorTileMap = {
        let node = TileMap(layer: .floors)
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()
    
    lazy var shadowTileMap = {
        let node = TileMap(layer: .shadows)
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()
    
    lazy var hero = {
        let node = Hero()
        node.position = .zero
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()
    
    lazy var boxContainer = {
        let node = SKNode()
        node.position = .zero
        return node
    }()

    lazy var wallTileMap = {
        let node = TileMap(layer: .walls)
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()
    
    override init() {
        super.init()
        
        addChild(floorTileMap)
        addChild(shadowTileMap)
        addChild(hero)
        addChild(boxContainer)
        addChild(wallTileMap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with map: Map) {
        // clear tilemaps
        floorTileMap.clear()
        shadowTileMap.clear()
        wallTileMap.clear()
        
        // set size
        floorTileMap.size = map.size
        shadowTileMap.size = map.size
        wallTileMap.size = map.size
        
        // draw tilemaps
        floorTileMap.draw(map: map)
        shadowTileMap.draw(map: map)
        wallTileMap.draw(map: map)
        
        boxContainer.removeAllChildren()
        for b in map.objectsOfType(.box) {
            let box = Box()
            box.id = b.id
            boxContainer.addChild(box)
        }
        updateObjectPositions(map)
        
        // scale small maps 2x
        let scale = map.size.width <= 12 && map.size.height <= 9 ? 2.0 : 1.0
        xScale = scale
        yScale = scale
    }
    
    func updateObjectPositions(_ map: Map) {
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

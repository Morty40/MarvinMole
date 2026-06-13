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
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50) // TODO ?
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }()

    lazy var shadowTileMap = {
        let node = TileMap(layer: .shadows)
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
        let node = TileMap(layer: .water)
        node.position = CGPoint(x: frame.size.width * 0.46, y: frame.size.height * 0.50)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
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
        addChild(waterTileMap)
        addChild(wallTileMap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with map: Map) {
        // clear tilemaps
        floorTileMap.clear()
        shadowTileMap.clear()
        waterTileMap.clear()
        wallTileMap.clear()
        
        // set size
        floorTileMap.size = map.size
        shadowTileMap.size = map.size
        waterTileMap.size = map.size
        wallTileMap.size = map.size
        
        // draw tilemaps
        floorTileMap.draw(map: map)
        shadowTileMap.draw(map: map)
        waterTileMap.draw(map: map)
        wallTileMap.draw(map: map)
        
        boxContainer.removeAllChildren()
        for b in map.objectsOfType(.box) {
            let box = Box(id: b.id)
            boxContainer.addChild(box)
        }
        updateObjectPositions(map)
        
        // map scale
        let scaleWidth = Double(1024 - 250) / Double(map.size.width * 32)
        let scaleHeight = Double(768 - 250) / Double(map.size.height * 32)
        let scale = min(3.0, CGFloat(min(scaleWidth, scaleHeight)))
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

    func toggleVisibility(layer: TileMap.Layer) {
        switch layer {
        case .floors:
            floorTileMap.isHidden.toggle()
        case .shadows:
            shadowTileMap.isHidden.toggle()
        case .water:
            waterTileMap.isHidden.toggle()
        case .walls:
            wallTileMap.isHidden.toggle()
        }
    }
    
}

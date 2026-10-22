//
//  WaterTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class WaterTileMap: SKTileMapNode {
        
    /// Animated water: the frames of the Water sheet, in a loop
    let water = SKTileGroup(tileDefinition: SKTileDefinition(textures: SKTexture(imageNamed: "Water").split(),
                                                             size: CGSize(width: 32, height: 32),
                                                             timePerFrame: 0.2))

    override init() {
        super.init()
        tileSet = SKTileSet(tileGroups: [water])
    }
    
    /// Draws water on the floor cells for which `isWater` is true, and on walls next to them
    /// (so the walls' rounded corners show water rather than floor)
    func draw(map: Map, isWater: (Int, Int) -> Bool) {
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {
                let tile = map.tileAt(x: x, y: y)
                let (c, r) = (x, numberOfRows - y - 1)
                let wet: Bool
                if tile.isFloor {
                    wet = isWater(x, y)
                } else if tile.isWall {
                    wet = isWater(x - 1, y) || isWater(x + 1, y) || isWater(x, y - 1) || isWater(x, y + 1)
                } else {
                    wet = false
                }
                setTileGroup(wet ? water : nil, forColumn: c, row: r)
            }
        }
    }

    func clear() {
        fill(with: nil)
    }
    
    var size: (width: Int, height: Int) {
        get { (numberOfColumns, numberOfRows) }
        set { (numberOfColumns, numberOfRows) = newValue }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

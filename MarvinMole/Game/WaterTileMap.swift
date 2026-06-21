//
//  WaterTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class WaterTileMap: SKTileMapNode {
        
    let waterFlooding = SKTileGroup(tileDefinition: SKTileDefinition(textures: SKTexture(imageNamed: "WaterFlooding").split(),
                                                                     size: CGSize(width: 32, height: 32),
                                                                     timePerFrame: 0.2))

    let waterDraining = SKTileGroup(tileDefinition: SKTileDefinition(textures: SKTexture(imageNamed: "WaterDraining").split(),
                                                                     size: CGSize(width: 32, height: 32),
                                                                     timePerFrame: 0.2))

    override init() {
        super.init()
        tileSet = SKTileSet(tileGroups: [waterFlooding, waterDraining])
    }
    
    func draw(map: Map, bfd: [[Int?]] = [], distance: Int = 0, isDraining: Bool = false) {
                
        func isWaterAt(x: Int, y: Int) -> Bool {
            var isWater = false
            if y >= 0 && y < bfd.count {
                let bfdRow = bfd[y]
                if x >= 0 && x < bfdRow.count {
                    isWater = bfdRow[x] ?? Int.max < distance
                }
            }
            return isWater
        }
        
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {
                
                let tile = map.tileAt(x: x, y: y)
                let (c, r) = (x, numberOfRows - y - 1)

                if tile.isFloor {

                    if isWaterAt(x: x, y: y) {
                        setTileGroup(isDraining ? waterDraining : waterFlooding,
                                     forColumn: c, row: r)
                    }

                } else if tile.isWall {

                    if isWaterAt(x: x-1, y: y) ||
                        isWaterAt(x: x+1, y: y) ||
                        isWaterAt(x: x, y: y-1) ||
                        isWaterAt(x: x, y: y+1) {
                        setTileGroup(isDraining ? waterDraining : waterFlooding,
                                     forColumn: c, row: r)
                    }
                    
                } else {
                    setTileGroup(nil, forColumn: c, row: r)
                }
                
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

//
//  ShadowTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class ShadowTileMap: SKTileMapNode {
    
    let wallShadows = SKTexture(imageNamed: "WallShadows").split().map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
    
    let shadows = SKTexture(imageNamed: "Shadows").split(columns: 3, rows: 3).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }

    override init() {
        super.init()
        tileSet = SKTileSet(tileGroups: wallShadows + shadows)
    }
    
    // TODO: fix me
    func draw(map: Map) {
        
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {

                let tile = map.tileAt(x: x, y: y)

                let tileLeft = map.tileAt(x: x-1, y: y)
                let tileLeftUp = map.tileAt(x: x-1, y: y-1)
                let tileUp = map.tileAt(x: x, y: y-1)

                let (c, r) = (x, numberOfRows - y - 1)
                
                switch tile {
                case .floor, .floorGoal:
                    if tileLeft.isWall, tileLeftUp.isWall, tileUp.isWall {
                        setTileGroup(shadows[0], forColumn: c, row: r)
                        
                    } else if tileLeft.isFloor, tileLeftUp.isWall, tileUp.isWall {
                        setTileGroup(shadows[1], forColumn: c, row: r)
                        
                    } /*else if tileLeft.isWall, tileLeftUp.isWall {
                        setTileGroup(tileSet.shadows[0], forColumn: c, row: r)
                        
                    } else if tileLeft.isWall, tileLeftUp != .wall {
                        setTileGroup(tileSet.shadows[0], forColumn: c, row: r)
                        
                    } else if tileUp.isWall, tileLeftUp.isWall {
                        setTileGroup(tileSet.shadows[0], forColumn: c, row: r)
                        
                    } else if tileUp.isWall, tileLeftUp != .wall {
                        setTileGroup(tileSet.shadows[0], forColumn: c, row: r)
                    }*/
break
                    
                case .wall:
                    if tileLeft.isCastingShadow, tileLeftUp.isCastingShadow, tileUp.isCastingShadow {
                        setTileGroup(wallShadows[0], forColumn: c, row: r)
                        
                    } else if tileLeft.isCastingShadow, tileLeftUp.isFloor, tileUp.isCastingShadow {
                        setTileGroup(wallShadows[1], forColumn: c, row: r)

                    } else if tileLeft.isFloor, tileLeftUp.isFloor, tileUp.isFloor {
                        setTileGroup(wallShadows[2], forColumn: c, row: r)

                    } else if tileLeft.isCastingShadow, tileUp.isFloor {
                        setTileGroup(wallShadows[3], forColumn: c, row: r)

                    } else if tileLeft.isFloor, tileUp.isCastingShadow {
                        setTileGroup(wallShadows[4], forColumn: c, row: r)
                    }

                default:
                    break
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

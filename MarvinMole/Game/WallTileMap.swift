//
//  WallTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class WallTileMap: SKTileMapNode {
        
    let outerWalls = SKTexture(imageNamed: "OuterWalls").split(columns: 3, rows: 7).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
    
    let innerWalls = SKTexture(imageNamed: "InnerWalls").split(columns: 3, rows: 5).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }

    override init() {
        super.init()
        tileSet = SKTileSet(tileGroups: outerWalls + innerWalls)
    }
    
    func draw(map: Map) {
        
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {

                let tile = map.tileAt(x: x, y: y)
                
                let tileLeft = map.tileAt(x: x-1, y: y)
                let tileLeftUp = map.tileAt(x: x-1, y: y-1)
                let tileUp = map.tileAt(x: x, y: y-1)
                let tileUpRight = map.tileAt(x: x+1, y: y-1)
                let tileRight = map.tileAt(x: x+1, y: y)
                let tileRightDown = map.tileAt(x: x+1, y: y+1)
                let tileDown = map.tileAt(x: x, y: y+1)
                let tileDownLeft = map.tileAt(x: x-1, y: y+1)

                let adjacentTiles = [tileLeft, tileUp, tileRight, tileDown, tileLeftUp, tileUpRight, tileRightDown, tileDownLeft]
                let isOuterWall = adjacentTiles.contains(where: { $0.isVoid })
                
                let (c, r) = (x, numberOfRows - y - 1)

                switch tile {
                case .wall:
                
                    if isOuterWall {
                        var index = 4
                        
                        if tileLeft.isVoid, tileLeftUp.isVoid, tileUp.isVoid {
                            index = 0
                            
                        } else if tileLeft.isWall, tileUp.isVoid, tileRight.isWall, tileDown.isFloor {
                            index = 1

                        } else if tileUp.isVoid, tileUpRight.isVoid, tileRight.isVoid {
                            index = 2

                        } else if tileLeft.isVoid, tileUp.isWall, tileDown.isWall {
                            index = 3

                        } else if tileUp.isWall, tileRight.isVoid, tileDown.isWall {
                            index = 5

                        } else if tileLeft.isVoid, tileDownLeft.isVoid, tileDown.isVoid {
                            index = 6

                        } else if tileLeft.isWall, tileUp.isFloor, tileRight.isWall, tileDown.isVoid {
                            index = 7

                        } else if tileRight.isVoid, tileRightDown.isVoid, tileDown.isVoid {
                            index = 8

                        } else if tileLeft.isFloor, tileLeftUp.isFloor, tileUp.isFloor, tileRight.isWall, tileRightDown.isVoid, tileDown.isWall {
                            index = 9

                        } else if tileLeft.isWall, tileUp.isFloor, tileRight.isWall, tileDown.isVoid {
                            index = 10

                        } else if tileLeft.isWall, tileUp.isFloor, tileUpRight.isFloor, tileRight.isFloor, tileDown.isWall {
                            index = 11

                        } else if tileLeft.isFloor, tileUp.isWall, tileUpRight.isVoid, tileRight.isWall, tileDown.isFloor, tileDownLeft.isFloor {
                            index = 12
                            
                        } else if tileLeft.isWall, tileLeftUp.isVoid, tileUp.isWall, tileRight.isFloor, tileRightDown.isFloor, tileDown.isFloor {
                            index = 14

                        } else if tileRight.isWall, tileRightDown.isVoid, tileDown.isWall {
                            index = 15

                        } else if tileLeft.isWall, tileUp.isWall, tileRight.isWall, tileDown.isVoid {
                            index = 16

                        } else if tileLeft.isWall, tileDown.isWall, tileDownLeft.isVoid {
                            index = 17
                            
                        } else if tileUp.isWall, tileUpRight.isVoid, tileRight.isWall {
                            index = 18
                            
                        } else if tileUp.isVoid, tileDown.isWall {
                            index = 19

                        } else if tileLeft.isWall, tileLeftUp.isVoid, tileUp.isWall {
                            index = 20
                        }
                        
                        setTileGroup(outerWalls[index], forColumn: c, row: r)
                        
                    } else {
                        var index = 3
                        
                        if tileLeft.isFloor, tileLeftUp.isFloor, tileUp.isFloor, tileRight.isWall, tileDown.isWall {
                            index = 0

                        } else if tileLeft.isWall, tileUp.isFloor, tileRight.isWall, tileDown.isFloor {
                            index = 1
                            
                        } else if tileLeft.isWall, tileUp.isFloor, tileUpRight.isFloor, tileRight.isFloor, tileDown.isWall {
                            index = 2
                            
                        } else if tileLeft.isWall, tileUp.isWall, tileRight.isWall, tileDown.isWall {
                            index = 3

                        } else if tileLeft.isWall, tileUp.isFloor, tileRight.isWall, tileDown.isWall {
                            index = 4

                        } else if tileLeft.isFloor, tileUp.isFloor, tileRight.isFloor, tileDown.isFloor {
                            index = 5

                        } else if tileLeft.isFloor, tileUp.isWall, tileRight.isWall, tileDown.isFloor, tileDownLeft.isFloor {
                            index = 6

                        } else if tileLeft.isWall, tileUp.isWall, tileRight.isWall, tileRightDown.isFloor, tileDown.isFloor, tileDownLeft.isFloor {
                            index = 7

                        } else if tileLeft.isWall, tileUp.isWall, tileRight.isFloor, tileRightDown.isFloor, tileDown.isFloor {
                            index = 8

                        } else if tileLeft.isFloor, tileUp.isFloor, tileRight.isFloor, tileDown.isWall {
                            index = 9

                        } else if tileLeft.isFloor, tileLeftUp.isFloor, tileUp.isFloor, tileRight.isWall, tileDown.isFloor {
                            index = 10
                            
                        } else if tileLeft.isWall, tileUp.isFloor, tileRight.isFloor, tileDown.isFloor {
                            index = 11

                        } else if tileLeft.isFloor, tileUp.isWall, tileRight.isFloor, tileDown.isFloor {
                            index = 12
                        }

                        setTileGroup(innerWalls[index], forColumn: c, row: r)
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

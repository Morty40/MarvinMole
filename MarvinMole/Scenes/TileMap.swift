//
//  TileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TileMap: SKTileMapNode {
    
    enum Layer {
        case floors
        case shadows
        case walls
    }
    
    private var layer: Layer
    
    init(layer: Layer) {
        self.layer = layer
        super.init()
        tileSet = TileSet()
    }
    
    private func drawFloors(map: Map, rect: (x: Int, y: Int, width: Int, height: Int)) {
        
        let tileSet = tileSet as! TileSet
        for y in rect.y ..< rect.y + rect.height {
            for x in rect.x ..< rect.x + rect.width {
                
                let tile = map.tileAt(x: x, y: y)
                let (c, r) = (x, numberOfRows - y - 1)

                switch tile {
                case .floor, .wall:
                    let n = tileSet.floors.count
                    setTileGroup(tileSet.floors[Int(arc4random()) % n], forColumn: c, row: r)
                    
                case .floorGoal:
                    setTileGroup(tileSet.goal, forColumn: c, row: r)
                    
                default:
                    break
                }
            }
        }
        
    }
    
    private func drawShadows(map: Map, rect: (x: Int, y: Int, width: Int, height: Int)) {
        
        let tileSet = tileSet as! TileSet
        for y in rect.y ..< rect.y + rect.height {
            for x in rect.x ..< rect.x + rect.width {

                let tile = map.tileAt(x: x, y: y)
                let tileLeft = map.tileAt(x: x-1, y: y)
                let tileUp = map.tileAt(x: x, y: y-1)
                let tileLeftUp = map.tileAt(x: x-1, y: y-1)
                let (c, r) = (x, numberOfRows - y - 1)
                
                switch tile {
                case .floor, .floorGoal:
                    if tileLeftUp.isWall, tileLeft != .wall, tileUp != .wall {
                        setTileGroup(tileSet.wallShadowLeftUp1, forColumn: c, row: r)
                        
                    } else if tileLeft.isWall, tileLeftUp != .wall, tileUp.isWall {
                        setTileGroup(tileSet.wallShadowLeftUp2, forColumn: c, row: r)
                        
                    } else if tileLeft.isWall, tileLeftUp.isWall {
                        setTileGroup(tileSet.wallShadowLeft1, forColumn: c, row: r)
                        
                    } else if tileLeft.isWall, tileLeftUp != .wall {
                        setTileGroup(tileSet.wallShadowLeft2, forColumn: c, row: r)
                        
                    } else if tileUp.isWall, tileLeftUp.isWall {
                        setTileGroup(tileSet.wallShadowUp1, forColumn: c, row: r)
                        
                    } else if tileUp.isWall, tileLeftUp != .wall {
                        setTileGroup(tileSet.wallShadowUp2, forColumn: c, row: r)
                    }

                case .wall:
                    setTileGroup(tileSet.wallShadowUnder, forColumn: c, row: r)

                default:
                    break
                }
            }
        }
        
    }
    
    private func drawWalls(map: Map, rect: (x: Int, y: Int, width: Int, height: Int)) {
        
        let tileSet = tileSet as! TileSet
        for y in rect.y ..< rect.y + rect.height {
            for x in rect.x ..< rect.x + rect.width {

                let tile = map.tileAt(x: x, y: y)
                
                let tileLeft = map.tileAt(x: x-1, y: y)
                let tileUp = map.tileAt(x: x, y: y-1)
                let tileRight = map.tileAt(x: x+1, y: y)
                let tileDown = map.tileAt(x: x, y: y+1)
                
                let tileLeftUp = map.tileAt(x: x-1, y: y-1)
                let tileUpRight = map.tileAt(x: x+1, y: y-1)
                let tileRightDown = map.tileAt(x: x+1, y: y+1)
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
                        
                        setTileGroup(tileSet.outerWallTextures[index], forColumn: c, row: r)
                        
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

                        setTileGroup(tileSet.innerWallTextures[index], forColumn: c, row: r)
                    }
                    
                default:
                    break
                }
            }
        }
        
    }
    
    func draw(map: Map, rect: (x: Int, y: Int, width: Int, height: Int)) {
        
        switch layer {
        case .floors:
            drawFloors(map: map, rect: rect)
        case .shadows:
            drawShadows(map: map, rect: rect)
        case .walls:
            drawWalls(map: map, rect: rect)
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

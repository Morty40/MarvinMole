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
        case water
        case walls
    }
    
    private var layer: Layer
    
    init(layer: Layer) {
        self.layer = layer
        super.init()
        tileSet = TileSet()
    }
    
    private func drawFloors(map: Map) {
        
        let tileSet = tileSet as! TileSet
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {
                
                let tile = map.tileAt(x: x, y: y)
                let (c, r) = (x, numberOfRows - y - 1)

                switch tile {
                case .floor, .wall:
                    let n = tileSet.floor.count
                    setTileGroup(tileSet.floor[(c+r) % n], forColumn: c, row: r)
                    
                case .floorGoal:
                    setTileGroup(tileSet.goal, forColumn: c, row: r)
                    
                default:
                    break
                }
            }
        }
        
    }

    private func drawShadows(map: Map) {
        
        let tileSet = tileSet as! TileSet
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
                        setTileGroup(tileSet.shadows[0], forColumn: c, row: r)
                        
                    } else if tileLeft.isFloor, tileLeftUp.isWall, tileUp.isWall {
                        setTileGroup(tileSet.shadows[1], forColumn: c, row: r)
                        
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
                        setTileGroup(tileSet.wallShadows[0], forColumn: c, row: r)
                        
                    } else if tileLeft.isCastingShadow, tileLeftUp.isFloor, tileUp.isCastingShadow {
                        setTileGroup(tileSet.wallShadows[1], forColumn: c, row: r)

                    } else if tileLeft.isFloor, tileLeftUp.isFloor, tileUp.isFloor {
                        setTileGroup(tileSet.wallShadows[2], forColumn: c, row: r)

                    } else if tileLeft.isCastingShadow, tileUp.isFloor {
                        setTileGroup(tileSet.wallShadows[3], forColumn: c, row: r)

                    } else if tileLeft.isFloor, tileUp.isCastingShadow {
                        setTileGroup(tileSet.wallShadows[4], forColumn: c, row: r)
                    }

                default:
                    break
                }
            }
        }
        
    }
    
    private func drawWater(map: Map, flooding: Double) {
        
        let tileSet = tileSet as! TileSet
        
        let cX = map.size.width / 2
        let cY = map.size.height / 2
        let distC = sqrt(Double(cX*cX) + Double(cY*cY))
        
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {
                
                let tile = map.tileAt(x: x, y: y)
                let (c, r) = (x, numberOfRows - y - 1)

                switch tile {
                case .floor, .floorGoal, .wall:
                    
                    let dX = cX-x
                    let dY = cY-y
                    let d = sqrt(Double(dX*dX) + Double(dY*dY))
                    let normalizedDistance = d/distC
                    let isWater = normalizedDistance < flooding

                    if isWater {
                        let n = tileSet.floor.count
                        setTileGroup(tileSet.animatedWater, forColumn: c, row: r)
                    } else {
                        setTileGroup(nil, forColumn: c, row: r)
                    }
                    
                default:
                    break
                }
            }
        }
        
    }

    private func drawWalls(map: Map) {
        
        let tileSet = tileSet as! TileSet
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
                        
                        setTileGroup(tileSet.outerWalls[index], forColumn: c, row: r)
                        
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

                        setTileGroup(tileSet.innerWalls[index], forColumn: c, row: r)
                    }
                    
                default:
                    break
                }
            }
        }
        
    }
    
    func draw(map: Map, flooding: Double = 0.0) {
        
        switch layer {
        case .floors:
            drawFloors(map: map)
        case .water:
            drawWater(map: map, flooding: flooding)
        case .shadows:
            drawShadows(map: map)
        case .walls:
            drawWalls(map: map)
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

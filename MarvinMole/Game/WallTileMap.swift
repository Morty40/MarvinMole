//
//  WallTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class WallTileMap: SKTileMapNode {
        
    /// The wall tiles are 64 pixels: drawn at 32 points, the same size as the other tile maps
    /// (and sharp on retina screens)
    private static let tileSize = CGSize(width: 32, height: 32)

    let outerWalls = SKTexture(imageNamed: "OuterWalls").split(columns: 3, rows: 7).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0, size: tileSize)) }
    
    let innerWalls = SKTexture(imageNamed: "InnerWalls").split(columns: 3, rows: 5).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0, size: tileSize)) }

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
                // a straight bottom edge (walls left, above and right, floor below) can only touch the
                // outside diagonally above it: it is drawn as an inner wall, the outer tile has grass in it
                let isBottomEdge = tileLeft.isWall && tileUp.isWall && tileRight.isWall && tileDown.isFloor
                let isOuterWall = !isBottomEdge && adjacentTiles.contains(where: { $0.isVoid })
                
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
                        // the shape (rounded corners, and the shaded front face at the bottom)
                        // only depends on the walls left, above, right and below; inner walls
                        // have floor all around, so anything else is floor
                        let index = switch (tileLeft.isWall, tileUp.isWall, tileRight.isWall, tileDown.isWall) {
                        case (false, false, false, false):  5   // single block
                        case (false, false, false, true):   9   // top end of a vertical wall
                        case (false, true, false, false):   12  // bottom end of a vertical wall
                        case (false, true, false, true):    3   // middle of a vertical wall
                        case (false, false, true, false):   10  // left end of a horizontal wall
                        case (true, false, false, false):   11  // right end of a horizontal wall
                        case (true, false, true, false):    1   // middle of a horizontal wall
                        case (false, false, true, true):    0   // top-left corner
                        case (true, false, false, true):    2   // top-right corner
                        case (false, true, true, false):    6   // bottom-left corner
                        case (true, true, false, false):    8   // bottom-right corner
                        case (true, false, true, true):     4   // top edge
                        case (true, true, true, false):     7   // bottom edge
                        case (false, true, true, true),         // left edge
                             (true, true, false, true),         // right edge
                             (true, true, true, true):      3   // inside
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

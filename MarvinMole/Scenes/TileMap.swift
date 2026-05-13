//
//  TileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TileMap: SKTileMapNode {
    
    override init() {
        super.init()
        tileSet = TileSet()
    }

    func draw(map: Map) {

        // clear
        for column in 0 ..< numberOfColumns {
            for row in 0 ..< numberOfRows {
                setTileGroup(nil, forColumn: column, row: row)
            }
        }
        
        // set size
        numberOfColumns = map.size.width
        numberOfRows = map.size.height
        
        // draw tiles
        let tileSet = tileSet as! TileSet
        for y in 0 ..< numberOfRows {
            for x in 0 ..< numberOfColumns {
                
                let tile = map.tileAt(x: x, y: y)
                let tileBelow = map.tileAt(x: x, y: y+1)
                let tileLeft = map.tileAt(x: x-1, y: y)

                switch tile {
                case .wall:
                    if tileBelow == .wall {
                        setTileGroup(tileSet.wallTop, forColumn: x, row: numberOfRows - y - 1)
                    } else {
                        setTileGroup(tileSet.wallFront, forColumn: x, row: numberOfRows - y - 1)
                    }
                    
                case .floor:
                    if tileLeft == .wall {
                        setTileGroup(tileSet.floorShadow, forColumn: x, row: numberOfRows - y - 1)
                    } else {
                        setTileGroup(tileSet.floor, forColumn: x, row: numberOfRows - y - 1)
                    }
                    
                case .goal:
                    setTileGroup(tileSet.goal, forColumn: x, row: numberOfRows - y - 1)
                default:
                    break
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

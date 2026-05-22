//
//  TileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TileMap: SKTileMapNode {
    
    private var mask = [Map.Tile]()
    
    init(mask: [Map.Tile]) {
        super.init()
        self.mask = mask
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
                let tileBelowLeft = map.tileAt(x: x-1, y: y+1)

                if !mask.contains(tile) { continue }
                
                switch tile {
                case .wall:
                    if tileBelow == .wall {
                        setTileGroup(tileSet.wallTop, forColumn: x, row: numberOfRows - y - 1)
                    } else {
                        if tileBelowLeft == .wall {
                            setTileGroup(tileSet.wallFrontShadow, forColumn: x, row: numberOfRows - y - 1)
                        } else {
                            let tile = ((arc4random() & 3) != 0) ? tileSet.wallFront1 : tileSet.wallFront2
                            setTileGroup(tile, forColumn: x, row: numberOfRows - y - 1)
                        }
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

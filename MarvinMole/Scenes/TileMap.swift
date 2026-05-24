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
                case .floor:
                    setTileGroup(tileSet.floors[Int(arc4random() & 3)], forColumn: c, row: r)
                    
                case .goal:
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
                case .floor, .goal:
                    if tileLeftUp == .wall, tileLeft != .wall, tileUp != .wall {
                        setTileGroup(tileSet.wallShadowLeftUp1, forColumn: c, row: r)
                    }
                    else if tileLeft == .wall, tileUp == .wall {
                        setTileGroup(tileSet.wallShadowLeftUp2, forColumn: c, row: r)
                    }
                    else if tileLeft == .wall, tileLeftUp == .wall {
                        setTileGroup(tileSet.wallShadowLeft1, forColumn: c, row: r)
                    }
                    else if tileLeft == .wall, tileLeftUp != .wall {
                        setTileGroup(tileSet.wallShadowLeft2, forColumn: c, row: r)
                    }
                    else if tileUp == .wall, tileLeftUp == .wall {
                        setTileGroup(tileSet.wallShadowUp1, forColumn: c, row: r)
                    }
                    else if tileUp == .wall, tileLeftUp != .wall {
                        setTileGroup(tileSet.wallShadowUp2, forColumn: c, row: r)
                    }

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
                let tileBelow = map.tileAt(x: x, y: y+1)
                let (c, r) = (x, numberOfRows - y - 1)

                switch tile {
                case .wall:
                    if tileBelow == .wall {
                        setTileGroup(tileSet.wallTop, forColumn: c, row: r)
                    } else {
                        let tile = ((arc4random() & 3) != 0) ? tileSet.wallFront1 : tileSet.wallFront2
                        setTileGroup(tile, forColumn: c, row: r)
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

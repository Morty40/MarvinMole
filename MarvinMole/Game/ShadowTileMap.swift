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
    
    /// Drop shadows of the walls, with the light coming from the top left:
    /// each wall (and the void around the map) casts its shape onto the floor, shifted right and down.
    ///
    /// A floor tile is shaded along its top edge when the tile above casts a shadow, and along its
    /// left edge when the tile to the left does. Where the shadow band starts at a tile without a
    /// wall diagonally up-left, it starts with a slanted edge; with only a wall diagonally up-left,
    /// just its corner is shaded.
    ///
    /// Under a wall, the shadow only shows through the transparent (rounded) corners of the wall
    /// tile: its bottom-right quarter is always shaded, the other quarters when the neighbouring
    /// tiles above, to the left, and up-left cast a shadow.
    func draw(map: Map) {
        
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {

                let tile = map.tileAt(x: x, y: y)

                let left = map.tileAt(x: x-1, y: y).isCastingShadow
                let leftUp = map.tileAt(x: x-1, y: y-1).isCastingShadow
                let up = map.tileAt(x: x, y: y-1).isCastingShadow

                let (c, r) = (x, numberOfRows - y - 1)
                
                switch tile {
                case .floor, .floorGoal:
                    let index: Int? = switch (left, leftUp, up) {
                    case (true, _, true):       0       // left and top edges
                    case (false, true, true):   1       // top edge
                    case (false, false, true):  3       // top edge, slanted start
                    case (true, true, false):   2       // left edge
                    case (true, false, false):  6       // left edge, slanted start
                    case (false, true, false):  5       // top-left corner
                    case (false, false, false): nil     // in the light
                    }
                    if let index {
                        setTileGroup(shadows[index], forColumn: c, row: r)
                    }

                case .wall:
                    let index = switch (left, up) {
                    case (true, true):      leftUp ? 0 : 1  // all quarters, or all but the top-left
                    case (true, false):     3               // bottom half
                    case (false, true):     4               // right half
                    case (false, false):    2               // bottom-right quarter
                    }
                    setTileGroup(wallShadows[index], forColumn: c, row: r)

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

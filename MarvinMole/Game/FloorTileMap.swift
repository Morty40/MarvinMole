//
//  FloorTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Floor under the map: random tiles from the Floor sheet (4 x 4 tiles), and cupboards on the goals.
class FloorTileMap: SKTileMapNode {
    
    /// The floor and goal tiles are 64 pixels: drawn at 32 points, the same size as the other
    /// tile maps (and sharp on retina screens)
    private static let tileSize = CGSize(width: 32, height: 32)

    let floor = SKTexture(imageNamed: "Floor").split(columns: 4, rows: 4).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0, size: tileSize)) }
    
    let goal = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "Goal"), size: tileSize))

    override init() {
        super.init()
        tileSet = SKTileSet(tileGroups: floor + [goal])
    }
    
    /// Draws the floor with random tiles. The layout is seeded, so the same seed always
    /// gives the same floor (e.g. every time a level is played).
    func draw(map: Map, seed: UInt64) {
        var state = seed &* 6364136223846793005 &+ 1442695040888963407
        func random(_ n: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(n))
        }

        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {
                
                let tile = map.tileAt(x: x, y: y)
                let (c, r) = (x, numberOfRows - y - 1)

                switch tile {
                case .floor, .wall:
                    setTileGroup(floor[random(floor.count)], forColumn: c, row: r)
                    
                case .floorGoal:
                    setTileGroup(goal, forColumn: c, row: r)
                    
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

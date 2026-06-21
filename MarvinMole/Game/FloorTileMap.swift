//
//  FloorTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class FloorTileMap: SKTileMapNode {
    
    let floor = SKTexture(imageNamed: "Floor").split().map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
    
    let goal = SKTileGroup(imageNamed: "Goal")

    override init() {
        super.init()
        tileSet = SKTileSet(tileGroups: floor + [goal])
    }
    
    func draw(map: Map) {
        
        for y in 0 ..< map.size.height {
            for x in 0 ..< map.size.width {
                
                let tile = map.tileAt(x: x, y: y)
                let (c, r) = (x, numberOfRows - y - 1)

                switch tile {
                case .floor, .wall:
                    let n = floor.count
                    setTileGroup(floor[(c+r) % n], forColumn: c, row: r)
                    
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

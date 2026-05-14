//
//  TileSet.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TileSet: SKTileSet {
    
    let wallFront1 = SKTileGroup(imageNamed: "WallFront1")
    let wallFront2 = SKTileGroup(imageNamed: "WallFront2")
    let wallTop = SKTileGroup(imageNamed: "WallTop")
    let floor = SKTileGroup(imageNamed: "Floor")
    let floorShadow: SKTileGroup = SKTileGroup(imageNamed: "FloorShadow")
    let goal = SKTileGroup(imageNamed: "Goal")
    
    override init() {
        super.init(tileGroups: [wallFront1, wallFront2, wallTop, floor, floorShadow, goal])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

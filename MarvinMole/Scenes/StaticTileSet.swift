//
//  StaticTileSet.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class StaticTileSet: SKTileSet {
    
    let wallFront = SKTileGroup(imageNamed: "WallFront")
    let wallTop = SKTileGroup(imageNamed: "WallTop")
    let floor = SKTileGroup(imageNamed: "Floor")
    let floorShadow: SKTileGroup = SKTileGroup(imageNamed: "FloorShadow")
    let goal = SKTileGroup(imageNamed: "Goal")
    
    override init() {
        super.init(tileGroups: [wallFront, wallTop, floor, floorShadow, goal])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

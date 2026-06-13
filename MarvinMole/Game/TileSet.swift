//
//  TileSet.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TileSet: SKTileSet {
    
    let floor = SKTexture(imageNamed: "Floor").split().map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }

    let water = SKTexture(imageNamed: "Water").split().map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }

    let goal = SKTileGroup(imageNamed: "Goal")
    
    let wallShadows = SKTexture(imageNamed: "WallShadows").split().map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
    
    let shadows = SKTexture(imageNamed: "Shadows").split(columns: 3, rows: 3).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
    
    let outerWalls = SKTexture(imageNamed: "OuterWalls").split(columns: 3, rows: 7).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
    
    let innerWalls = SKTexture(imageNamed: "InnerWalls").split(columns: 3, rows: 5).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
    
    override init() {
        super.init(tileGroups: floor + water + [goal] + wallShadows + shadows + outerWalls + innerWalls)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
    let wallFrontShadow = SKTileGroup(imageNamed: "WallFrontShadow")
    let wallTop = SKTileGroup(imageNamed: "WallTop")
    
    var floor: SKTileGroup
    var floors: [SKTileGroup]

    let goal = SKTileGroup(imageNamed: "Goal")

    // wall shadows
    let wallShadowLeft1 = SKTileGroup(imageNamed: "WallShadowLeft1")
    let wallShadowLeft2 = SKTileGroup(imageNamed: "WallShadowLeft2")
    let wallShadowUp1 = SKTileGroup(imageNamed: "WallShadowUp1")
    let wallShadowUp2 = SKTileGroup(imageNamed: "WallShadowUp2")
    let wallShadowLeftUp1 = SKTileGroup(imageNamed: "WallShadowLeftUp1")
    let wallShadowLeftUp2 = SKTileGroup(imageNamed: "WallShadowLeftUp2")
    
    override init() {
        let floorTextures = SKTexture(imageNamed: "Floor").split()
        floor = SKTileGroup(tileDefinition: SKTileDefinition(texture: floorTextures[0]))
        
        floors = floorTextures.map { SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }
        
        super.init(tileGroups: [wallShadowLeft1, wallShadowLeft2,
                                wallShadowUp1, wallShadowUp2,
                                wallShadowLeftUp1, wallShadowLeftUp2,
                                wallFront1, wallFront2,
                                wallFrontShadow, wallTop, floor, goal] + floors)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

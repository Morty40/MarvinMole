//
//  SKTileGroup+Init.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

extension SKTileGroup {
    
    /// Create a tile group with a single texture
    /// - Parameter imageNamed: Name of image
    convenience init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        let tileDefinition = SKTileDefinition(texture: texture, size: texture.size())
        self.init(tileDefinition: tileDefinition)
    }
}

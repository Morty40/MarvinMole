//
//  Hero.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Hero: GameObjectNode {
    
    // walking
    static let walkLeftTextures = SKTexture(imageNamed: "HeroWalkLeft").split(columns: 8)
    static let walkUpTextures = SKTexture(imageNamed: "HeroWalkUp").split(columns: 8)
    static let walkRightTextures = SKTexture(imageNamed: "HeroWalkRight").split(columns: 8)
    static let walkDownTextures = SKTexture(imageNamed: "HeroWalkDown").split(columns: 8)
    
    // pushing
    static let pushLeftTextures = SKTexture(imageNamed: "HeroWalkLeft").split(columns: 8)
    static let pushUpTextures = SKTexture(imageNamed: "HeroWalkUp").split(columns: 8)
    static let pushRightTextures = SKTexture(imageNamed: "HeroWalkRight").split(columns: 8)
    static let pushDownTextures = SKTexture(imageNamed: "HeroWalkDown").split(columns: 8)
    
    /// Animation action for a hero walk/push move
    /// - Parameters:
    ///   - move: Move type
    ///   - distance: Distance to travel
    ///   - duration: Duration of animation
    /// - Returns: Action
    func actionFor(move: Map.Move,
                   distance: CGFloat,
                   duration: TimeInterval = 0.3) -> SKAction {
        
        var textures: [SKTexture]
        var dx, dy: CGFloat
        
        switch move {
        case .walkLeft:  (textures, dx, dy) = (Hero.walkLeftTextures, -distance, 0)
        case .walkUp:    (textures, dx, dy) = (Hero.walkUpTextures, 0, distance)
        case .walkRight: (textures, dx, dy) = (Hero.walkRightTextures, distance, 0)
        case .walkDown:  (textures, dx, dy) = (Hero.walkDownTextures, 0, -distance)
        case .pushLeft:  (textures, dx, dy) = (Hero.pushLeftTextures, -distance, 0)
        case .pushUp:    (textures, dx, dy) = (Hero.pushUpTextures, 0, distance)
        case .pushRight: (textures, dx, dy) = (Hero.pushRightTextures, distance, 0)
        case .pushDown:  (textures, dx, dy) = (Hero.pushDownTextures, 0, -distance)
        }
        
        let action = SKAction.group([
            SKAction.animate(with: textures, timePerFrame: duration / Double(textures.count)),
            SKAction.moveBy(x: dx, y: dy, duration: duration)])
        action.timingMode = .linear
        return action
    }
}

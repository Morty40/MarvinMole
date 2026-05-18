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

    // idling
    static let idleTextures = SKTexture(imageNamed: "HeroIdle").split(columns: 3)

    /// Animation action for a hero walk/push move
    /// - Parameters:
    ///   - move: Move type
    ///   - distance: Distance to travel
    ///   - duration: Duration of animation
    /// - Returns: Action
    func actionFor(move: Map.Move,
                   distance: CGFloat,
                   duration: TimeInterval = 0.4) -> SKAction {
        
        var dx, dy: CGFloat
        var textures: [SKTexture]
        
        switch move {
        case .walkLeft:
            (dx, dy, textures) = (-distance, 0, Hero.walkLeftTextures)
        case .walkUp:
            (dx, dy, textures) = (0, distance, Hero.walkUpTextures)
        case .walkRight:
            (dx, dy, textures) = (distance, 0, Hero.walkRightTextures)
        case .walkDown:
            (dx, dy, textures) = (0, -distance, Hero.walkDownTextures)
        case .pushLeft:
            (dx, dy, textures) = (-distance, 0, Hero.pushLeftTextures)
        case .pushUp:
            (dx, dy, textures) = (0, distance, Hero.pushUpTextures)
        case .pushRight:
            (dx, dy, textures) = (distance, 0, Hero.pushRightTextures)
        case .pushDown:
            (dx, dy, textures) = (0, -distance, Hero.pushDownTextures)
        }
        
        // create action that moves the object and animates the texture
        let action = SKAction.group([
            SKAction.moveBy(x: dx, y: dy, duration: duration),
            SKAction.animate(with: textures, timePerFrame: duration / Double(textures.count))])
        action.timingMode = .linear
        return action
    }

    var lastTime: TimeInterval = 0.0
    var deltaTime: TimeInterval = 0.0
    func update(_ currentTime: TimeInterval) {
        if lastTime == 0.0 {
            lastTime = currentTime
        }
        
        deltaTime = currentTime - lastTime
        lastTime = currentTime
    }
    
    private var idleIndex: Int = 0
    private var frameTime: TimeInterval = 0.0
    
    func idle() {
        frameTime += deltaTime
        if frameTime > 0.2 {
            frameTime = 0.0
            
            let idleFrames = [0, 0, 1, 1, 0, 0, 1, 1,
                              0, 0, 1, 1, 0, 0, 1, 1,
                              2, 0, 1, 1, 0, 2, 1, 1]
            texture = Hero.idleTextures[idleFrames[idleIndex]]
            idleIndex = (idleIndex + 1) % idleFrames.count
        }
    }
}

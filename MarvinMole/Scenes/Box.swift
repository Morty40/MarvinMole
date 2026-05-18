//
//  Box.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Box: GameObjectNode {
    
    static let boxTextures = [SKTexture(imageNamed: "Box1"),
                              SKTexture(imageNamed: "Box2"),
                              SKTexture(imageNamed: "Box3"),
                              SKTexture(imageNamed: "Box4"),
                              SKTexture(imageNamed: "Box5")]
    static let boxOnGoalTexture = SKTexture(imageNamed: "BoxOnGoal")
    
    var boxTexture: SKTexture? = nil
    
    override init() {
        super.init()
        boxTexture = Box.boxTextures[Int(arc4random()) % Box.boxTextures.count]
        self.texture = boxTexture
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func actionFor(move: Map.Move,
                   distance: CGFloat,
                   duration: TimeInterval = 0.4) -> SKAction? {
        
        var dx, dy: CGFloat
        
        switch move {
        case .pushLeft:
            (dx, dy) = (-distance, 0)
        case .pushUp:
            (dx, dy) = (0, distance)
        case .pushRight:
            (dx, dy) = (distance, 0)
        case .pushDown:
            (dx, dy) = (0, -distance)
        default:
            return nil
        }
        
        let action = SKAction.moveBy(x: dx, y: dy, duration: duration)
        action.timingMode = .linear
        return action
    }

    
}

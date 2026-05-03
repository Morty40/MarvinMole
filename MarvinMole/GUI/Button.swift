//
//  Button.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Button: SKSpriteNode {
    
    private var target: Any? = nil
    private var action: Selector? = nil
    
    private let texture1 = SKTexture(imageNamed: "ButtonNormal")
    private let texture2 = SKTexture(imageNamed: "ButtonPressed")
    
    init(target: Any?, action: Selector?) {
        super.init(texture: texture1,
                   color: .clear,
                   size: CGSize(width: 250, height: 100))

        self.target = target
        self.action = action

        self.isUserInteractionEnabled = true
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = texture2
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = texture1
        
        if let touch = touches.first {
            
            // translate touch event coordinate to node local coordinate
            let locationInNode = touch.location(in: self)
            
            // check if inside (outside doesn't count as tap on button)
            if locationInNode.x > -size.width/2,
               locationInNode.x < size.width/2,
               locationInNode.y > -size.height/2,
               locationInNode.y < size.height/2 {
                
                // run selector on target
                if let target = target, let action = action {
                    run(SKAction.perform(action, onTarget: target))
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = texture1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

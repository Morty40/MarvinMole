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
    
    private(set) var isPressed = false
    
    private var sfx = SKAction.playSoundFileNamed("ButtonClick.wav", waitForCompletion: false)
    
    init(target: Any?, action: Selector?) {
        super.init(texture: nil,
                   color: .clear,
                   size: .zero)
        
        self.target = target
        self.action = action
        
        self.isUserInteractionEnabled = true
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Button {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isPressed = true

        run(sfx)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isPressed = false

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
        super.touchesCancelled(touches, with: event)
        isPressed = false
    }
    
}

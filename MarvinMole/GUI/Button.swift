//
//  Button.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Button: SKSpriteNode {

    /// 9-slice button frame (64 x 64 points), see `centerRect`
    static let normalTexture = SKTexture(imageNamed: "ButtonNormal")
    static let pressedTexture = SKTexture(imageNamed: "ButtonPressed")

    /// The 28 point border of the frame (rim and rounded corners) keeps its size, only the centre is stretched
    static let frameCenterRect = CGRect(x: 28.0 / 64.0, y: 28.0 / 64.0,
                                        width: 8.0 / 64.0, height: 8.0 / 64.0)

    private var target: Any? = nil
    private var action: Selector? = nil
    
    private(set) var isPressed = false

    /// Optional action for a long press (held for `longPressDuration`), run on `target` instead of the
    /// normal action: the press is handled once it is long enough, and releasing it does nothing more
    var longPressAction: Selector? = nil

    /// The same duration as UIKit's long press gesture
    static let longPressDuration: TimeInterval = 0.5

    private var isLongPressHandled = false
    
    private var sfx = SKAction.playSoundFileNamed("ButtonClick.wav", waitForCompletion: false)
    
    init(target: Any?, action: Selector?) {
        super.init(texture: nil,
                   color: .clear,
                   size: .zero)
        
        self.target = target
        self.action = action
        
        self.isUserInteractionEnabled = true
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.centerRect = Button.frameCenterRect
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Button {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isPressed = true
        isLongPressHandled = false

        run(sfx)

        if let target, let longPressAction {
            run(SKAction.sequence([SKAction.wait(forDuration: Self.longPressDuration),
                                   SKAction.run { [weak self] in self?.isLongPressHandled = true },
                                   SKAction.perform(longPressAction, onTarget: target)]),
                withKey: "longPress")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isPressed = false
        removeAction(forKey: "longPress")

        if !isLongPressHandled, let touch = touches.first {
            
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
        removeAction(forKey: "longPress")
    }
    
}

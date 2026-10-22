//
//  FloatingText.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class FloatingText: SKLabelNode {
        
    private var label: SKLabelNode!

    /// Seconds the text is shown: longer texts get more time to read (about 16 characters per second
    /// on top of a second), within limits
    let duration: TimeInterval
    
    init(text: String) {
        duration = min(max(1.0 + 0.06 * Double(text.count), 1.2), 3.5)
        super.init()
        
        fontName = "Rubik-Bold"
        fontSize = 20
        horizontalAlignmentMode = .center
        verticalAlignmentMode = .center

        let attributes1: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .strokeWidth: -10.0,
            .foregroundColor: UIColor.black,
            .font: UIFont(name: fontName!, size: fontSize)!
        ]
        attributedText = NSAttributedString(string: text,
                                            attributes: attributes1)
        
        let attributes2: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .strokeWidth: 0.0,
            .foregroundColor: UIColor.systemCyan,
            .font: UIFont(name: fontName!, size: fontSize)!
        ]

        label = SKLabelNode()
        label.horizontalAlignmentMode = horizontalAlignmentMode
        label.verticalAlignmentMode = verticalAlignmentMode
        label.fontName = fontName
        label.fontSize = fontSize
        label.position = .zero
        label.attributedText = NSAttributedString(string: text,
                                                  attributes: attributes2)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Floats up slowly (10 points per second) for `duration` seconds, fading out at the end
    func runAnimation() {
        let moveUp = SKAction.moveBy(x: 0, y: 10 * duration, duration: duration)
        
        let wait = SKAction.wait(forDuration: duration - 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let fadeOutSequence = SKAction.sequence([wait, fadeOut])
        
        let group = SKAction.group([moveUp, fadeOutSequence])
        
        let removeSelf = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([group, removeSelf])

        run(sequence)
    }

}

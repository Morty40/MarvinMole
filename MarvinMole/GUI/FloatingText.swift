//
//  FloatingText.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class FloatingText: SKLabelNode {
        
    private var bgLabel: SKLabelNode!
    
    override init() {
        super.init()
        
        bgLabel = SKLabelNode()
        bgLabel.fontColor = UIColor(white: 0.0, alpha: 0.5)
        bgLabel.position = .zero
        bgLabel.zPosition = -0.1 // relative to parent
        addChild(bgLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var verticalAlignmentMode: SKLabelVerticalAlignmentMode {
        didSet {
            self.verticalAlignmentMode = .center
            bgLabel.verticalAlignmentMode = .center
        }
    }
    
    override var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode {
        didSet { (children as! [SKLabelNode]).forEach { $0.horizontalAlignmentMode = horizontalAlignmentMode } }
    }
    
    override var numberOfLines: Int {
        didSet { (children as! [SKLabelNode]).forEach { $0.numberOfLines = numberOfLines } }
    }
    
    override var lineBreakMode: NSLineBreakMode {
        didSet { (children as! [SKLabelNode]).forEach { $0.lineBreakMode = lineBreakMode } }
    }

    override var preferredMaxLayoutWidth: CGFloat {
        didSet { (children as! [SKLabelNode]).forEach { $0.preferredMaxLayoutWidth = preferredMaxLayoutWidth } }
    }
    
    override var fontName: String? {
        didSet { (children as! [SKLabelNode]).forEach { $0.fontName = fontName } }
    }
    
    override var fontSize: CGFloat {
        didSet { (children as! [SKLabelNode]).forEach { $0.fontSize = fontSize } }
    }

    
    override var text: String? {
        didSet { (children as! [SKLabelNode]).forEach { $0.text = text } }
    }

}

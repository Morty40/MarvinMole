//
//  TextButton.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TextButton: Button {
        
    private let texture1 = SKTexture(imageNamed: "ButtonNormal")
    private let texture2 = SKTexture(imageNamed: "ButtonPressed")

    private lazy var titleLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.fontColor = .white
        node.position = CGPoint(x: 0, y: -10)
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        node.zPosition = 1
        return node
    }()

    init(title: String, target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    
        texture = texture1
        size = CGSize(width: 250, height: 100)

        titleLabel.text = title
        addChild(titleLabel)
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        texture = texture2
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        texture = texture1
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        texture = texture1
    }

}

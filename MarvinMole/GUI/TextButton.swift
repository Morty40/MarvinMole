//
//  TextButton.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TextButton: Button {
        
    private lazy var titleLabel = {
        let node = SKLabelNode()
        node.fontName = "Avenir-Black"
        node.fontColor = .white
        node.position = .zero
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.zPosition = 2
        return node
    }()

    init(title: String, target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    
        titleLabel.text = title
        addChild(titleLabel)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

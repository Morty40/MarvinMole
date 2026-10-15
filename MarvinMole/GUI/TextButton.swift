//
//  TextButton.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class TextButton: Button {
        
    private let texture1 = Button.normalTexture
    private let texture2 = Button.pressedTexture

    private static let fontName = "Rubik-Bold"
    private static let fontSize: CGFloat = 32

    /// The title is aligned to its baseline, so titles with descenders ("Easy") sit at the same
    /// height as titles without. The baseline is placed so the capital letters are centred.
    private static let titlePosition = CGPoint(x: 0, y: -(UIFont(name: fontName, size: fontSize)?.capHeight ?? 22) / 2)

    /// Black outline around the title, same width as the icon outlines (2.2 points):
    /// black copies of the title, placed in a circle behind it
    private static let outlineWidth: CGFloat = 2.2
    private static let outlineCopies = 16

    private lazy var titleLabel = {
        let node = makeLabel(color: .white)
        node.position = Self.titlePosition
        node.zPosition = 2
        return node
    }()

    private lazy var outlineLabels = {
        (0 ..< Self.outlineCopies).map { i in
            let angle = 2 * CGFloat.pi * CGFloat(i) / CGFloat(Self.outlineCopies)
            let node = makeLabel(color: .black)
            node.position = CGPoint(x: Self.titlePosition.x + Self.outlineWidth * cos(angle),
                                    y: Self.titlePosition.y + Self.outlineWidth * sin(angle))
            node.zPosition = 1
            return node
        }
    }()

    private func makeLabel(color: UIColor) -> SKLabelNode {
        let node = SKLabelNode()
        node.fontName = Self.fontName
        node.fontSize = Self.fontSize
        node.fontColor = color
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .baseline
        return node
    }

    init(title: String, target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    
        texture = texture1
        size = CGSize(width: 250, height: 100)

        self.title = title
        outlineLabels.forEach { addChild($0) }
        addChild(titleLabel)
    }
    
    var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
            outlineLabels.forEach { $0.text = newValue }
        }
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

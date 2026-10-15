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
    private static let titleFontSize: CGFloat = 32
    private static let subtitleFontSize: CGFloat = 20

    /// Vertical gap between the title and the subtitle (bottom of title capitals to top of subtitle capitals)
    private static let lineSpacing: CGFloat = 8

    private lazy var titleLabel = OutlinedLabel(fontName: Self.fontName, fontSize: Self.titleFontSize)
    private lazy var subtitleLabel = OutlinedLabel(fontName: Self.fontName, fontSize: Self.subtitleFontSize)

    init(title: String, subtitle: String? = nil, target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    
        texture = texture1
        size = CGSize(width: 250, height: 100)

        addChild(titleLabel)
        addChild(subtitleLabel)
        self.title = title
        self.subtitle = subtitle
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    /// Optional second line in a smaller font, below the title
    var subtitle: String? {
        get { subtitleLabel.text }
        set {
            subtitleLabel.text = newValue
            layoutLabels()
        }
    }

    /// Centres the capitals of the title, or of the title and subtitle together, in the button.
    /// Both are aligned to their baseline, so descenders ("Easy") don't move the text.
    private func layoutLabels() {
        let hasSubtitle = !(subtitle ?? "").isEmpty
        subtitleLabel.isHidden = !hasSubtitle
        let titleHeight = titleLabel.capHeight
        if hasSubtitle {
            let height = titleHeight + Self.lineSpacing + subtitleLabel.capHeight
            titleLabel.position = CGPoint(x: 0, y: height / 2 - titleHeight)
            subtitleLabel.position = CGPoint(x: 0, y: -height / 2)
        } else {
            titleLabel.position = CGPoint(x: 0, y: -titleHeight / 2)
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

/// White text with a black outline, the same width as the icon outlines (2.2 points):
/// black copies of the text, placed in a circle behind it. Aligned to the baseline.
private class OutlinedLabel: SKNode {

    private static let outlineWidth: CGFloat = 2.2
    private static let outlineCopies = 16

    let capHeight: CGFloat

    private let label: SKLabelNode
    private let outline: [SKLabelNode]

    init(fontName: String, fontSize: CGFloat) {
        capHeight = UIFont(name: fontName, size: fontSize)?.capHeight ?? fontSize * 0.7

        func makeLabel(color: UIColor) -> SKLabelNode {
            let node = SKLabelNode()
            node.fontName = fontName
            node.fontSize = fontSize
            node.fontColor = color
            node.horizontalAlignmentMode = .center
            node.verticalAlignmentMode = .baseline
            return node
        }

        label = makeLabel(color: .white)
        label.zPosition = 2
        outline = (0 ..< Self.outlineCopies).map { i in
            let angle = 2 * CGFloat.pi * CGFloat(i) / CGFloat(Self.outlineCopies)
            let node = makeLabel(color: .black)
            node.position = CGPoint(x: Self.outlineWidth * cos(angle),
                                    y: Self.outlineWidth * sin(angle))
            node.zPosition = 1
            return node
        }
        super.init()

        outline.forEach { addChild($0) }
        addChild(label)
    }

    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            outline.forEach { $0.text = newValue }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

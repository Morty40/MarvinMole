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

    /// Black outline around the title, same width as the icon outlines (2.2 points).
    /// The stroke is centred on the glyph edges, so it is twice that width, and drawn
    /// behind the title label, which covers the inner half.
    private static let outlineWidth: CGFloat = 2.2
    private static let outlineAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: fontName, size: fontSize)!,
        .foregroundColor: UIColor.black,
        .strokeColor: UIColor.black,
        .strokeWidth: -2 * outlineWidth / fontSize * 100,     // percent of the font size, negative = fill too
    ]

    // the title is attributed text too, so both labels are aligned the same way
    private static let titleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: fontName, size: fontSize)!,
        .foregroundColor: UIColor.white,
    ]

    private var titleText: String? = nil

    /// Both labels are centred vertically: the stroked outline label is rendered with extra
    /// padding, which stays symmetric around the centre (unlike with baseline alignment)
    private static let titlePosition = CGPoint(x: 0, y: 1)

    private lazy var titleLabel = {
        let node = SKLabelNode()
        node.position = Self.titlePosition
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.zPosition = 2
        return node
    }()

    private lazy var outlineLabel = {
        let node = SKLabelNode()
        node.position = Self.titlePosition
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.zPosition = 1
        return node
    }()

    init(title: String, target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    
        texture = texture1
        size = CGSize(width: 250, height: 100)

        self.title = title
        addChild(outlineLabel)
        addChild(titleLabel)
    }
    
    var title: String? {
        get { titleText }
        set {
            titleText = newValue
            titleLabel.attributedText = NSAttributedString(string: newValue ?? "",
                                                           attributes: Self.titleAttributes)
            outlineLabel.attributedText = NSAttributedString(string: newValue ?? "",
                                                             attributes: Self.outlineAttributes)
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

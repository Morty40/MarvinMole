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

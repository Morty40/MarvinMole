//
//  ModalPopup.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Modal popup with an optional title, a body text and one or two buttons at the bottom.
/// It dims the scene behind it and swallows all touches until a button is pressed.
///
///     let popup = ModalPopup(title: "Quit?", message: "Are you sure?",
///                            buttons: [.init(title: "Yes") { ... }, .init(title: "No")])
///     popup.show(in: scene)
class ModalPopup: SKSpriteNode {

    struct Action {
        let title: String
        let handler: (() -> Void)?

        init(title: String, handler: (() -> Void)? = nil) {
            self.title = title
            self.handler = handler
        }
    }

    /// 9-slice popup frame (100 x 100 points), same wood style as the buttons
    private static let backgroundTexture = SKTexture(imageNamed: "PopupBackground")

    /// The 46 point border of the frame keeps its size, only the centre is stretched
    private static let frameCenterRect = CGRect(x: 46.0 / 100.0, y: 46.0 / 100.0,
                                                width: 8.0 / 100.0, height: 8.0 / 100.0)

    private static let fontName = "Rubik-Bold"
    private static let titleFontSize: CGFloat = 40
    private static let messageFontSize: CGFloat = 28

    private static let width: CGFloat = 600
    private static let padding: CGFloat = 44
    private static let spacing: CGFloat = 28
    private static let buttonSize = CGSize(width: 220, height: 90)
    private static let buttonSpacing: CGFloat = 24

    /// Is a popup showing in this scene?
    static func isShowing(in scene: SKScene) -> Bool {
        scene.children.contains { $0 is ModalPopup }
    }

    private let actions: [Action]

    private lazy var titleLabel = OutlinedLabel(fontName: Self.fontName,
                                                fontSize: Self.titleFontSize,
                                                verticalAlignment: .top,
                                                maxWidth: Self.width - 2 * Self.padding)

    private lazy var messageLabel = OutlinedLabel(fontName: Self.fontName,
                                                  fontSize: Self.messageFontSize,
                                                  verticalAlignment: .top,
                                                  maxWidth: Self.width - 2 * Self.padding)

    /// The box itself; the popup node is the dimmed full-screen backdrop
    private lazy var box = {
        let node = SKSpriteNode(texture: Self.backgroundTexture)
        node.centerRect = Self.frameCenterRect
        node.zPosition = 1
        return node
    }()

    /// - Parameters:
    ///   - title: Optional title, at the top
    ///   - message: Body text, wrapped to several lines if needed
    ///   - buttons: One or two buttons, left to right; the popup closes before the handler runs
    init(title: String? = nil, message: String, buttons: [Action]) {
        precondition((1 ... 2).contains(buttons.count), "ModalPopup takes 1 or 2 buttons")
        actions = buttons

        super.init(texture: nil, color: UIColor(white: 0, alpha: 0.5), size: .zero)

        // the backdrop swallows touches outside the box, so the scene behind can't be used
        isUserInteractionEnabled = true
        zPosition = 1000

        addChild(box)
        box.addChild(messageLabel)
        let hasTitle = !(title ?? "").isEmpty
        if hasTitle {
            box.addChild(titleLabel)
            titleLabel.text = title
        }
        messageLabel.text = message

        // layout from the top: title, message, buttons
        let titleHeight = hasTitle ? titleLabel.textSize.height + Self.spacing : 0
        let messageHeight = messageLabel.textSize.height
        let height = Self.padding + titleHeight + messageHeight
                   + Self.spacing + Self.buttonSize.height + Self.padding
        box.size = CGSize(width: Self.width, height: height)

        var y = height / 2 - Self.padding
        titleLabel.position = CGPoint(x: 0, y: y)
        y -= titleHeight
        messageLabel.position = CGPoint(x: 0, y: y)

        let buttonY = -height / 2 + Self.padding + Self.buttonSize.height / 2
        let rowWidth = CGFloat(buttons.count) * Self.buttonSize.width
                     + CGFloat(buttons.count - 1) * Self.buttonSpacing
        for (i, action) in buttons.enumerated() {
            let selector = i == 0 ? #selector(onButton0) : #selector(onButton1)
            let button = TextButton(title: action.title, target: self, action: selector)
            button.size = Self.buttonSize
            button.position = CGPoint(x: -rowWidth / 2 + Self.buttonSize.width / 2
                                         + CGFloat(i) * (Self.buttonSize.width + Self.buttonSpacing),
                                      y: buttonY)
            button.zPosition = 1
            box.addChild(button)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Shows the popup centred on top of the scene
    func show(in scene: SKScene) {
        size = scene.size
        position = CGPoint(x: scene.size.width * (0.5 - scene.anchorPoint.x),
                           y: scene.size.height * (0.5 - scene.anchorPoint.y))
        scene.addChild(self)
    }

    /// Closes the popup. The completion runs a moment later, once the scene has been
    /// drawn without the popup, so e.g. a scene transition doesn't capture the popup.
    func dismiss(completion: (() -> Void)? = nil) {
        guard let scene else {
            completion?()
            return
        }
        removeFromParent()
        if let completion {
            scene.run(SKAction.sequence([SKAction.wait(forDuration: 0.15),
                                         SKAction.run(completion)]))
        }
    }

    @objc private func onButton0() {
        dismiss(completion: actions[0].handler)
    }

    @objc private func onButton1() {
        dismiss(completion: actions[1].handler)
    }
}

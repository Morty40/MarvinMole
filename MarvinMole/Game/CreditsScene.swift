//
//  CreditsScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Credits, shown by the menu now and then (taking turns with the demo).
/// Tapping anywhere, any key or some time passing goes back to the menu.
class CreditsScene: Scene {

    private var startTime: TimeInterval = 0.0

    /// Set once going back to the menu, so it only happens once
    private var isClosing = false

    // TODO: own background image
    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "CreditsBackground")
        node.position = center
        node.size = size
        node.zPosition = -10
        return node
    }()

    /// Headings, each followed by its names, one per line, top to bottom
    private let credits: [(heading: String, names: [String])] = [
        ("a game by:", ["Morten Perriard", "Guus Oosterbaan"]),
    ]

    private let headingFontSize: CGFloat = 30
    private let nameFontSize: CGFloat = 46

    /// Space above a heading, and between lines within a group
    private let groupSpacing: CGFloat = 90
    private let lineSpacing: CGFloat = 24

    /// The credits as centered lines, the whole block centered on the screen
    private lazy var creditLabels: [OutlinedLabel] = {
        func makeLabel(_ text: String, fontSize: CGFloat) -> OutlinedLabel {
            let node = OutlinedLabel(fontName: "Rubik-Bold", fontSize: fontSize)
            node.text = text
            return node
        }

        // stack the lines by cap height, baseline aligned
        var labels: [OutlinedLabel] = []
        var gaps: [CGFloat] = []
        for (heading, names) in credits {
            let headingLabel = makeLabel(heading, fontSize: headingFontSize)
            if !labels.isEmpty {
                gaps.append(groupSpacing + headingLabel.capHeight)
            }
            labels.append(headingLabel)
            for name in names {
                let nameLabel = makeLabel(name, fontSize: nameFontSize)
                gaps.append(lineSpacing + nameLabel.capHeight)
                labels.append(nameLabel)
            }
        }
        let height = labels[0].capHeight + gaps.reduce(0, +)
        var baseline = center.y + height / 2 - labels[0].capHeight
        for (i, label) in labels.enumerated() {
            if i > 0 {
                baseline -= gaps[i - 1]
            }
            label.position = CGPoint(x: center.x, y: baseline)
        }
        return labels
    }()

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()

        addChild(backgroundImage)
        creditLabels.forEach { addChild($0) }
    }

    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        startTime = 0.0
        isClosing = false
    }

    private func close() {
        if !isClosing {
            isClosing = true
            transition(to: Scene.menuScene)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // a tap anywhere goes back to the menu
        close()
    }

    override func handleKey(_ key: UIKey) {
        // any key goes back to the menu
        close()
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        // automatically go back to the menu after some time
        if startTime.isZero {
            startTime = currentTime
        } else if currentTime - startTime > 15.0 {
            close()
        }
    }
}

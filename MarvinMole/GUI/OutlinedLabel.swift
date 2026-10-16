//
//  OutlinedLabel.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// White text with a black outline, the same width as the icon outlines (2.2 points):
/// black copies of the text, placed in a circle behind it.
/// Single line text is aligned to the baseline by default; set `maxWidth` for wrapped, multi-line text.
class OutlinedLabel: SKNode {

    private static let outlineWidth: CGFloat = 2.2
    private static let outlineCopies = 16

    /// Opacity of the outline. The outline copies overlap, so they are drawn opaque into one
    /// layer, and the whole layer gets this opacity (an even outline, no darker overlaps).
    private static let outlineOpacity: CGFloat = 0.8

    let capHeight: CGFloat

    private let label: SKLabelNode
    private let outline: [SKLabelNode]
    private let outlineLayer: SKEffectNode

    init(fontName: String,
         fontSize: CGFloat,
         horizontalAlignment: SKLabelHorizontalAlignmentMode = .center,
         verticalAlignment: SKLabelVerticalAlignmentMode = .baseline,
         maxWidth: CGFloat? = nil) {
        capHeight = UIFont(name: fontName, size: fontSize)?.capHeight ?? fontSize * 0.7

        func makeLabel(color: UIColor) -> SKLabelNode {
            let node = SKLabelNode()
            node.fontName = fontName
            node.fontSize = fontSize
            node.fontColor = color
            node.horizontalAlignmentMode = horizontalAlignment
            node.verticalAlignmentMode = verticalAlignment
            if let maxWidth {
                node.numberOfLines = 0
                node.preferredMaxLayoutWidth = maxWidth
                node.lineBreakMode = .byWordWrapping
            }
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
        outlineLayer = SKEffectNode()
        outlineLayer.shouldRasterize = true
        outlineLayer.alpha = Self.outlineOpacity
        outlineLayer.zPosition = 1
        super.init()

        outline.forEach { outlineLayer.addChild($0) }
        addChild(outlineLayer)
        addChild(label)
    }

    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            outline.forEach { $0.text = newValue }
        }
    }

    /// Size of the text, without the outline
    var textSize: CGSize {
        label.frame.size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  BackgroundSprite.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// A background image covering the whole scene: centred, and scaled up evenly (never stretched) until it
/// fills both the width and the height; what doesn't fit is cropped.
/// With a focus point it can slowly pan and zoom in on that point (a Ken Burns effect).
class BackgroundSprite: SKSpriteNode {

    /// The point to zoom in on, in unit coordinates of the image, from its top-left corner
    /// (as measured in an image editor); nil for no Ken Burns effect
    var focus: CGPoint?

    /// How long the pan and zoom takes, and how far it zooms in
    private let kenBurnsDuration: TimeInterval = 20.0
    private let kenBurnsZoom: CGFloat = 1.01

    /// The size of the scene to cover
    private var sceneSize: CGSize = .zero

    init(imageNamed name: String, focus: CGPoint?, sceneSize: CGSize) {
        let texture = SKTexture(imageNamed: name)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.sceneSize = sceneSize
        setImage(named: name, focus: focus)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Shows another image, covering the scene, with its own focus point; back at full screen
    func setImage(named name: String, focus: CGPoint?) {
        texture = SKTexture(imageNamed: name)
        self.focus = focus
        resetKenBurns()
    }

    /// Back at full screen (centred, unzoomed), with no pan and zoom going on
    func resetKenBurns() {
        removeAction(forKey: "kenBurns")
        setScale(1.0)
        size = Scene.coverSize(of: texture?.size() ?? sceneSize, in: sceneSize)
        position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
    }

    /// Starts from full screen, then slowly pans and zooms in on the focus point, moving it towards the
    /// middle of the scene as far as the image still covers the whole scene. Call when the scene is presented.
    func startKenBurns() {
        resetKenBurns()
        guard let focus else {
            return
        }
        // the focus point, from the image's centre, and where the centre must move to bring it to the
        // middle of the scene once zoomed, kept so the zoomed image still covers the scene
        let offset = CGPoint(x: (focus.x - 0.5) * size.width, y: (0.5 - focus.y) * size.height)
        let slack = CGSize(width: (size.width * kenBurnsZoom - sceneSize.width) / 2,
                           height: (size.height * kenBurnsZoom - sceneSize.height) / 2)
        let target = CGPoint(x: position.x + min(max(-offset.x * kenBurnsZoom, -slack.width), slack.width),
                             y: position.y + min(max(-offset.y * kenBurnsZoom, -slack.height), slack.height))

        let panAndZoom = SKAction.group([SKAction.scale(to: kenBurnsZoom, duration: kenBurnsDuration),
                                         SKAction.move(to: target, duration: kenBurnsDuration)])
        panAndZoom.timingMode = .easeInEaseOut
        run(panAndZoom, withKey: "kenBurns")
    }
}

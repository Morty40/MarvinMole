//
//  ProgressScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Shown between levels, after a level is completed: a background with rain, dripping water and music,
/// and a "Next" button, which starts the next level in the game scene.
class ProgressScene: Scene {

    /// Rain falling over the whole background: in front of it, behind the text and button (as on the menu)
    private lazy var rain = {
        let node = RainEmitter(size: size)
        node.position.x += center.x
        node.position.y += center.y
        node.zPosition = -1
        return node
    }()

    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "ProgressBackground")
        node.position = center
        node.size = size
        node.zPosition = -10
        return node
    }()

    /// Margin to the screen edges, the same as the game scene's GUI
    private let margin: CGFloat = 16

    /// Story text in the top-right corner, right aligned; same font, size and width as on the menu
    private lazy var storyText = {
        let node = OutlinedLabel(fontName: "Rubik-Bold",
                                 fontSize: 30,
                                 horizontalAlignment: .right,
                                 verticalAlignment: .top,
                                 maxWidth: frame.size.width * 0.65)
        node.position = CGPoint(x: frame.size.width - margin, y: frame.size.height - margin)
        node.text = "Oh dear!  Just as Marvin Mole finished up in one place, he needs to hurry to the next.  He would be so grateful for your help again."
        return node
    }()

    /// In the bottom-right corner
    private lazy var nextButton = {
        let node = TextButton(title: "Next", target: self, action: #selector(onNext))
        node.position = CGPoint(x: frame.size.width - margin - node.size.width / 2,
                                y: margin + node.size.height / 2)
        return node
    }()

    @objc private func onNext() {
        MusicPlayer.shared.fadeOut(duration: 1.0)
        Scene.gameScene.startCurrentMap(from: self)
    }

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()

        addChild(backgroundImage)
        addChild(rain)
        addChild(storyText)
        addChild(nextButton)
    }

    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        rain.prewarm()
        startDripping()
        MusicPlayer.shared.play(Self.musicFile, volume: 0.6)    // same level as the menu, drips audible on top
    }

    override func willMove(from view: SKView) {
        stopDripping()
        // the music fades out when the next level starts
    }

    /// Background music: "Hurry Along", an original loop rendered by Artwork/Music/compose_progress_music.py
    private static let musicFile = "ProgressMusic.m4a"
}

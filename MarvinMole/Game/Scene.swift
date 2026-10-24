//
//  Scene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class Scene: SKScene {
    
    static let creditsScene = CreditsScene()
    static let demoScene = DemoScene()
    static let digScene = DigScene()
    static let floodScene = FloodScene()
    static let gameScene = GameScene()
    static let menuScene = MenuScene()
    static let progressScene = ProgressScene()

    /// All scenes are 768 points high, and as wide as the screen's shape asks for: 1024 points on a
    /// 4:3 iPad, up to about 1170 on wider ones. Shown with `.aspectFit` at exactly the screen's shape,
    /// a scene fills the whole screen (no black bars) without being stretched, and everything in it has
    /// the same size, relative to the screen's height, on every iPad.
    static let designHeight: CGFloat = 768

    /// The size of every scene, from the screen (in landscape; never narrower than 4:3)
    static let sceneSize: CGSize = {
        let bounds = UIScreen.main.bounds
        let aspect = max(bounds.width, bounds.height) / min(bounds.width, bounds.height)
        return CGSize(width: (designHeight * max(aspect, 4.0 / 3.0)).rounded(), height: designHeight)
    }()

    override init() {
        super.init(size: Scene.sceneSize)
        backgroundColor = .black
        scaleMode = .aspectFit
        anchorPoint = .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transition(to scene: SKScene, animated: Bool = true) {
        if animated {
            let transition = SKTransition.chessboard(snakeDuration: 0.6, waitDuration: 0.4, from: self)
            //let transition = SKTransition.crossFade(withDuration: 0.1)
            view?.presentScene(scene, transition: transition)
        } else {
            view?.presentScene(scene)
        }
    }
    
    func handleKey(_ key: UIKey) {
    }
    
    var center: CGPoint {
        CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }

    /// A background image that covers the whole scene: centred, and scaled up evenly (never stretched)
    /// until it fills both the width and the height; what doesn't fit is cropped.
    /// - Parameter focus: The point to slowly pan and zoom in on (see `BackgroundSprite.startKenBurns`),
    ///   in unit coordinates of the image from its top-left corner; nil for a still image
    func backgroundSprite(imageNamed name: String, focus: CGPoint? = nil) -> BackgroundSprite {
        BackgroundSprite(imageNamed: name, focus: focus, sceneSize: size)
    }

    /// The size of an image (of `imageSize`'s shape) scaled evenly to cover `area`
    static func coverSize(of imageSize: CGSize, in area: CGSize) -> CGSize {
        let scale = max(area.width / imageSize.width, area.height / imageSize.height)
        return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }
}

//
//  Box.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Box sprite
class Box: Sprite {
    
    /// Food: Food00 ... Food09 (64 x 64 pixels, drawn at 32 points); a level uses one of them for all its boxes
    static let boxTextures = (0 ..< 10).map { SKTexture(imageNamed: String(format: "Food%02d", $0)) }
    /// Crates: FoodInCrate00 ... FoodInCrate09, each with its food (the same index) showing at the top
    static let crateTextures = (0 ..< 10).map { SKTexture(imageNamed: String(format: "FoodInCrate%02d", $0)) }
    
    var boxTexture: SKTexture? = nil
    var crateTexture: SKTexture? = nil

    /// Played when food turns into a crate or a crate back into food, one picked at random each time
    private static let crateSounds = (1 ... 2).map {
        SKAction.playSoundFileNamed("FoodCrate\($0).wav", waitForCompletion: false)
    }
    
    /// - Parameters:
    ///   - id: The box's object id in the map
    ///   - type: Which food it is, an index into `boxTextures`
    init(id: Int, type: Int) {
        super.init(id: id)
        boxTexture = Box.boxTextures[type % Box.boxTextures.count]
        crateTexture = Box.crateTextures[type % Box.crateTextures.count]
        self.texture = boxTexture
    }
    
    /// Whether the box is a crate (on a cabinet), or will be once its current push has finished.
    /// Set when a push starts, and only then (not when its picture changes at the end): the next push
    /// can start a moment before the previous push has finished.
    private var isCrate = false

    /// Shows the box as a crate when it stands on a cabinet (goal) tile, otherwise as food
    func updateTexture(on tile: Map.Tile) {
        isCrate = tile == .floorGoal
        showCrate(isCrate)
    }

    /// Only the picture: a crate or food
    private func showCrate(_ crate: Bool) {
        texture = crate ? crateTexture : boxTexture
    }

    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func actionFor(move: Map.Move,
                   toTile: Map.Tile,
                   distance: CGFloat,
                   duration: TimeInterval = 0.4) -> SKAction? {
        
        var dx, dy: CGFloat
        
        switch move {
        case .pushLeft:
            (dx, dy) = (-distance, 0)
        case .pushUp:
            (dx, dy) = (0, distance)
        case .pushRight:
            (dx, dy) = (distance, 0)
        case .pushDown:
            (dx, dy) = (0, -distance)
        default:
            return nil
        }
        
        // food pushed onto a cabinet turns into a crate, and a crate pushed off a cabinet turns back
        // into food, both with a pop and a puff of dust
        let changes = (toTile == .floorGoal) != isCrate
        isCrate = toTile == .floorGoal

        let action = SKAction.sequence([
            SKAction.moveBy(x: dx, y: dy, duration: duration),
            SKAction.run { [weak self] in
                guard let self else { return }
                // only the picture: the state was set when the push started, and a newer push
                // may already have started (when a button is held, it can start a frame before this)
                self.showCrate(toTile == .floorGoal)
                if changes {
                    self.run(Box.crateSounds.randomElement()!)
                }
                // no pop when the crate is already disappearing into its cabinet: the level's completion
                // can start a frame before this, and the pop would stop it disappearing
                if changes, !self.isDisappearing {
                    self.popIn()
                }
            }])
        action.timingMode = .linear
        return action
    }

    /// Squash and stretch: the box lands flattened, springs up a little too tall, and settles,
    /// with a puff of dust around it. It squashes onto the floor: its bottom edge stays put.
    private func popIn() {
        let half = size.height / 2
        func shape(_ x: CGFloat, _ y: CGFloat, from previousY: CGFloat, _ duration: TimeInterval) -> SKAction {
            SKAction.group([SKAction.scaleX(to: x, duration: duration),
                            SKAction.scaleY(to: y, duration: duration),
                            SKAction.moveBy(x: 0, y: (y - previousY) * half, duration: duration)])
        }
        let squash = shape(1.3, 0.7, from: 1.0, 0.07)
        let stretch = shape(0.88, 1.18, from: 0.7, 0.09)
        let settle = shape(1.0, 1.0, from: 1.18, 0.14)
        squash.timingMode = .easeOut
        stretch.timingMode = .easeInEaseOut
        settle.timingMode = .easeOut
        run(SKAction.sequence([squash, stretch, settle]), withKey: "pop")

        puff(with: Self.dustTexture)
    }

    /// How long a crate takes to disappear into its cabinet
    static let disappearDuration: TimeInterval = 0.3

    /// Set once the crate is disappearing into its cabinet
    private var isDisappearing = false

    /// Played as a crate disappears into its cabinet and the cabinet closes, one picked at random each time
    private static let cabinetCloseSounds = (1 ... 2).map {
        SKAction.playSoundFileNamed("CabinetClose\($0).wav", waitForCompletion: false)
    }

    /// The crate shrinks into its cabinet and is gone, with a puff of smoke (the level is completed)
    func disappearIntoCabinet() {
        isDisappearing = true
        removeAction(forKey: "pop")
        puff(with: Self.smokeTexture)
        run(Self.cabinetCloseSounds.randomElement()!)
        let shrink = SKAction.group([SKAction.scale(to: 0.2, duration: Self.disappearDuration),
                                     SKAction.fadeOut(withDuration: Self.disappearDuration)])
        shrink.timingMode = .easeIn
        run(SKAction.sequence([shrink, SKAction.hide()]), withKey: "pop")
    }

    /// Placed on a tile (e.g. at the start, or after an undo): a pop in progress stops, at full size
    override func setMapPosition(x: Int, y: Int, tileMap: SKTileMapNode) {
        removeAction(forKey: "pop")
        isDisappearing = false
        setScale(1.0)
        alpha = 1.0
        isHidden = false
        super.setMapPosition(x: x, y: y, tileMap: tileMap)
    }

    /// A soft, round puff of dust, light brown and fading out towards its edge
    private static let dustTexture = puffTexture(red: 0.86, green: 0.78, blue: 0.64)

    /// A soft, round puff of smoke, pale grey and fading out towards its edge
    private static let smokeTexture = puffTexture(red: 0.9, green: 0.9, blue: 0.88)

    private static func puffTexture(red: CGFloat, green: CGFloat, blue: CGFloat) -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [UIColor(red: red, green: green, blue: blue, alpha: 0.9).cgColor,
                          UIColor(red: red, green: green, blue: blue, alpha: 0).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            let centre = CGPoint(x: size.width / 2, y: size.height / 2)
            context.cgContext.drawRadialGradient(gradient, startCenter: centre, startRadius: 0,
                                                 endCenter: centre, endRadius: size.width / 2, options: [])
        }
        return SKTexture(image: image)
    }

    /// Little clouds (of dust or smoke) that burst out from under the box, grow and fade away.
    /// They are added next to the box (not to it), so the squash and stretch doesn't distort them.
    private func puff(with texture: SKTexture) {
        guard let parent else {
            return
        }
        let count = 8
        for i in 0 ..< count {
            let angle = 2 * CGFloat.pi * (CGFloat(i) + CGFloat.random(in: -0.3 ... 0.3)) / CGFloat(count)
            let puff = SKSpriteNode(texture: texture)
            puff.size = CGSize(width: 14, height: 14)
            puff.position = CGPoint(x: position.x + 8 * cos(angle), y: position.y - 6 + 6 * sin(angle))
            puff.zPosition = zPosition + 1
            puff.alpha = 0.9
            puff.setScale(CGFloat.random(in: 0.6 ... 0.9))
            parent.addChild(puff)

            let duration = TimeInterval.random(in: 0.4 ... 0.55)
            let distance = CGFloat.random(in: 12 ... 18)
            let move = SKAction.moveBy(x: distance * cos(angle), y: distance * sin(angle) * 0.6 + 3, duration: duration)
            move.timingMode = .easeOut
            let grow = SKAction.scale(to: CGFloat.random(in: 1.4 ... 1.8), duration: duration)
            grow.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: duration)
            fade.timingMode = .easeIn
            puff.run(SKAction.sequence([SKAction.group([move, grow, fade]), SKAction.removeFromParent()]))
        }
    }
    
}

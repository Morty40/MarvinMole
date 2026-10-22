//
//  Box.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Box sprite
class Box: Sprite {
    
    /// Food: Box00 ... Box09 (64 x 64 pixels, drawn at 32 points); a level uses one of them for all its boxes
    static let boxTextures = (0 ..< 10).map { SKTexture(imageNamed: String(format: "Box%02d", $0)) }
    static let boxOnGoalTexture = SKTexture(imageNamed: "BoxOnGoal")
    
    var boxTexture: SKTexture? = nil
    
    /// - Parameters:
    ///   - id: The box's object id in the map
    ///   - type: Which food it is, an index into `boxTextures`
    init(id: Int, type: Int) {
        super.init(id: id)
        boxTexture = Box.boxTextures[type % Box.boxTextures.count]
        self.texture = boxTexture
    }
    
    /// Whether the box is a crate (on a cupboard), or will be once its current push has finished.
    /// Set when a push starts, and only then (not when its picture changes at the end): the next push
    /// can start a moment before the previous push has finished.
    private var isCrate = false

    /// Shows the box as a crate when it stands on a cupboard (goal) tile, otherwise as food
    func updateTexture(on tile: Map.Tile) {
        isCrate = tile == .floorGoal
        showCrate(isCrate)
    }

    /// Only the picture: a crate or food
    private func showCrate(_ crate: Bool) {
        texture = crate ? Box.boxOnGoalTexture : boxTexture
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
        
        // food pushed onto a cupboard turns into a crate, and a crate pushed off a cupboard turns back
        // into food, both with a pop and a puff of dust
        let changes = (toTile == .floorGoal) != isCrate
        isCrate = toTile == .floorGoal

        let action = SKAction.sequence([
            SKAction.moveBy(x: dx, y: dy, duration: duration),
            SKAction.run { [weak self] in
                // only the picture: the state was set when the push started, and a newer push
                // may already have started (when a button is held, it can start a frame before this)
                self?.showCrate(toTile == .floorGoal)
                if changes {
                    self?.popIn()
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

        puffDust()
    }

    /// Placed on a tile (e.g. at the start, or after an undo): a pop in progress stops, at full size
    override func setMapPosition(x: Int, y: Int, tileMap: SKTileMapNode) {
        removeAction(forKey: "pop")
        setScale(1.0)
        super.setMapPosition(x: x, y: y, tileMap: tileMap)
    }

    /// A soft, round puff of dust, light brown and fading out towards its edge
    private static let dustTexture: SKTexture = {
        let size = CGSize(width: 32, height: 32)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [UIColor(red: 0.86, green: 0.78, blue: 0.64, alpha: 0.9).cgColor,
                          UIColor(red: 0.86, green: 0.78, blue: 0.64, alpha: 0).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            let centre = CGPoint(x: size.width / 2, y: size.height / 2)
            context.cgContext.drawRadialGradient(gradient, startCenter: centre, startRadius: 0,
                                                 endCenter: centre, endRadius: size.width / 2, options: [])
        }
        return SKTexture(image: image)
    }()

    /// Little clouds of dust that burst out from under the box, grow and fade away.
    /// They are added next to the box (not to it), so the squash and stretch doesn't distort them.
    private func puffDust() {
        guard let parent else {
            return
        }
        let count = 8
        for i in 0 ..< count {
            let angle = 2 * CGFloat.pi * (CGFloat(i) + CGFloat.random(in: -0.3 ... 0.3)) / CGFloat(count)
            let puff = SKSpriteNode(texture: Self.dustTexture)
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

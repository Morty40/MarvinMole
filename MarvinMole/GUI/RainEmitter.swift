//
//  RainEmitter.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Rain falling straight down over an area, as a particle emitter.
/// Drops are born just above the area and live long enough to fall through all of it.
class RainEmitter: SKEmitterNode {

    /// A thin raindrop streak, transparent at the top and brightest at the bottom
    private static let dropTexture: SKTexture = {
        let size = CGSize(width: 8, height: 64)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [UIColor(white: 1, alpha: 0).cgColor,
                          UIColor(white: 1, alpha: 1).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: colors,
                                      locations: [0, 1])!
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                                    cornerRadius: size.width / 2)
            path.addClip()
            context.cgContext.drawLinearGradient(gradient,
                                                 start: .zero,
                                                 end: CGPoint(x: 0, y: size.height),
                                                 options: [])
        }
        return SKTexture(image: image)
    }()

    /// - Parameter size: Size of the area the rain covers, centred on the emitter's parent position
    init(size: CGSize) {
        super.init()

        particleTexture = Self.dropTexture
        particleColor = UIColor(red: 0.80, green: 0.88, blue: 1.0, alpha: 1)
        particleColorBlendFactor = 1

        // emit across the full width, at random heights in a band one screen tall above the top edge,
        // so drops don't all enter the screen in step
        let fallSpeed: CGFloat = 2000
        let band = size.height
        position = CGPoint(x: 0, y: size.height / 2 + 40 + band / 2)
        particlePositionRange = CGVector(dx: size.width, dy: band)

        // straight down, with some variation in speed for depth
        emissionAngle = -.pi / 2
        emissionAngleRange = 0
        particleSpeed = fallSpeed
        particleSpeedRange = 300
        particleLifetime = (size.height + band + 120) / (fallSpeed - 150)

        particleBirthRate = 10
        particleScale = 0.6
        particleScaleRange = 0.4
        particleAlpha = 0.35
        particleAlphaRange = 0.2
        particleBlendMode = .add
    }

    /// Fill the area with rain right away, as if it had been raining for a while.
    /// Call this once the emitter is in a scene that's being presented: SpriteKit ignores
    /// simulation time advanced before that.
    func prewarm() {
        resetSimulation()
        advanceSimulationTime(TimeInterval(particleLifetime + particleLifetimeRange / 2))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

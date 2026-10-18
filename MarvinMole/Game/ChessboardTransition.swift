//
//  ChessboardTransition.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit
import CoreImage

/// Transition filter: two snakes fill the squares of a chess board, spiralling inwards.
/// One starts top-left moving right, the other bottom-right moving left; each square flips
/// from fully transparent to fully opaque, until the old scene is covered.
/// After a wait with the screen fully covered, the process runs backwards to reveal the new scene.
///
/// SpriteKit sets `inputImage` (old scene) and `inputTargetImage` (new scene),
/// see `SKTransition(ciFilter:duration:)`. SpriteKit also sets `inputTime`, but its
/// easing and duration vary from transition to transition, so the filter keeps its own
/// clock instead, based on `inputSnakeDuration` and `inputWaitDuration`.
final class ChessboardTransitionFilter: CIFilter {

    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputTargetImage: CIImage?
    @objc dynamic var inputTime: NSNumber = 0

    /// Snapshot of the old scene, taken before the transition starts.
    /// SpriteKit's own `inputImage` is still empty on the first frame, which shows as a black blink.
    @objc dynamic var inputSnapshotImage: CIImage?

    /// Optional overlay (e.g. the level title), scene sized, shown while the screen is fully covered
    @objc dynamic var inputOverlayImage: CIImage?

    /// Seconds for the snakes to cover the whole screen (and again to uncover it)
    @objc dynamic var inputSnakeDuration: NSNumber = 0.5

    /// Seconds the screen stays fully covered, before uncovering
    @objc dynamic var inputWaitDuration: NSNumber = 0.2

    /// Total duration: cover, wait, uncover
    var totalDuration: TimeInterval {
        2 * inputSnakeDuration.doubleValue + inputWaitDuration.doubleValue
    }

    /// Time of the first rendered frame, the start of the filter's own clock
    private var startTime: CFTimeInterval?

    // board layout and look
    // (static, because SpriteKit copies the filter using the plain init())
    private static let columns = 8
    private static let rows = 6
    // two blues from the face gradient of the MARVIN MOLE title logo
    private static let colors = [CIColor(red: 49/255, green: 109/255, blue: 156/255),  // logo medium blue
                                 CIColor(red: 24/255, green: 62/255, blue: 114/255)]   // logo navy

    /// Time each square flips to opaque, as a fraction of the snake duration,
    /// indexed by `row * columns + column` (row 0 is the bottom row)
    private static let flipTimes: [Double] = {
        let steps = spiralSteps(columns: columns, rows: rows)

        // evenly spaced flip times, one per snake step
        // (the last step flips at the end of the snake duration, covering the whole screen)
        let numberOfSteps = (steps.max() ?? 0) + 1
        return steps.map { Double($0 + 1) / Double(numberOfSteps) }
    }()

    /// The step at which each square is filled by the two snakes
    /// - Parameters:
    ///   - columns: Number of columns
    ///   - rows: Number of rows
    /// - Returns: Step per square, indexed by `row * columns + column` (row 0 is the bottom row)
    static func spiralSteps(columns: Int, rows: Int) -> [Int] {
        struct Snake {
            var x: Int, y: Int        // y = 0 is the top row
            var direction: Int        // index into `directions`
            var isMoving = true
        }

        // clockwise: right, down, left, up
        let directions = [(1, 0), (0, 1), (-1, 0), (0, -1)]

        var steps = [Int?](repeating: nil, count: columns * rows)
        func index(_ x: Int, _ y: Int) -> Int { (rows - 1 - y) * columns + x }
        func isFree(_ x: Int, _ y: Int) -> Bool {
            x >= 0 && x < columns && y >= 0 && y < rows && steps[index(x, y)] == nil
        }

        // top-left moving right, bottom-right moving left
        var snakes = [Snake(x: 0, y: 0, direction: 0),
                      Snake(x: columns - 1, y: rows - 1, direction: 2)]
        var step = 0
        for snake in snakes {
            steps[index(snake.x, snake.y)] = step
        }

        while snakes.contains(where: \.isMoving) {
            step += 1
            for i in snakes.indices where snakes[i].isMoving {
                var snake = snakes[i]

                // straight ahead, or else turn 90 degrees clockwise
                snake.isMoving = false
                for turn in 0 ... 1 {
                    let direction = (snake.direction + turn) % directions.count
                    let (dx, dy) = directions[direction]
                    if isFree(snake.x + dx, snake.y + dy) {
                        snake.x += dx
                        snake.y += dy
                        snake.direction = direction
                        snake.isMoving = true
                        steps[index(snake.x, snake.y)] = step
                        break
                    }
                }
                snakes[i] = snake
            }
        }

        // squares no snake reached (not possible on a rectangle, but be safe) go last
        return steps.map { $0 ?? step }
    }

    // SpriteKit copies the filter using the plain init()
    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var outputImage: CIImage? {
        guard let inputImage, let inputTargetImage else {
            return nil
        }

        // seconds since the first frame
        let now = CACurrentMediaTime()
        let elapsed = now - (startTime ?? now)
        if startTime == nil {
            startTime = now
        }

        let snakeDuration = max(inputSnakeDuration.doubleValue, 0.001)
        let total = totalDuration
        if elapsed >= total {
            // done; SpriteKit may still be running its own (longer) clock
            return inputTargetImage
        }

        // covering and waiting: the old scene, uncovering: the new scene
        // (the screen is fully covered while switching)
        let extent = inputImage.extent
        let isCovering = elapsed < snakeDuration + inputWaitDuration.doubleValue / 2
        let background = isCovering ? oldScene(fitting: extent) ?? inputImage : inputTargetImage

        // snake progress, 0 ... 1 while covering, held at 1 while waiting,
        // then 1 ... 0 while uncovering (the same sequence backwards)
        let progress = min(elapsed, total - elapsed) / snakeDuration

        let (columns, rows, colors, flipTimes) = (Self.columns, Self.rows, Self.colors, Self.flipTimes)
        var board = CIImage.empty()

        for row in 0 ..< rows {
            for column in 0 ..< columns {
                if progress < flipTimes[row * columns + column] {
                    continue
                }

                // round the edges, so neighbouring squares meet without seams
                let x0 = (extent.minX + extent.width * CGFloat(column) / CGFloat(columns)).rounded()
                let x1 = (extent.minX + extent.width * CGFloat(column + 1) / CGFloat(columns)).rounded()
                let y0 = (extent.minY + extent.height * CGFloat(row) / CGFloat(rows)).rounded()
                let y1 = (extent.minY + extent.height * CGFloat(row + 1) / CGFloat(rows)).rounded()

                let square = CIImage(color: colors[(row + column) % colors.count])
                    .cropped(to: CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0))

                board = square.composited(over: board)
            }
        }

        var output = board.composited(over: background)
        if progress >= 1, let overlay = fitted(inputOverlayImage, in: extent) {
            output = overlay.composited(over: output)
        }
        return output.cropped(to: extent)
    }

    /// A scene sized image fitted inside `extent` keeping its aspect ratio, centred
    /// (the same way the view shows the scene)
    private func fitted(_ image: CIImage?, in extent: CGRect) -> CIImage? {
        guard let image, !image.extent.isEmpty else {
            return nil
        }
        let scale = min(extent.width / image.extent.width, extent.height / image.extent.height)
        let scaled = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return scaled.transformed(by: CGAffineTransform(translationX: extent.midX - scaled.extent.midX,
                                                        y: extent.midY - scaled.extent.midY))
    }

    /// The snapshot of the old scene, fitted inside `extent` keeping its aspect ratio,
    /// centered on black, the same way the view shows the scene (`.aspectFit`)
    private func oldScene(fitting extent: CGRect) -> CIImage? {
        guard let snapshot = inputSnapshotImage, !snapshot.extent.isEmpty else {
            return nil
        }
        let scale = min(extent.width / snapshot.extent.width,
                        extent.height / snapshot.extent.height)
        let image = snapshot.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let centered = image.transformed(by: CGAffineTransform(translationX: extent.midX - image.extent.midX,
                                                              y: extent.midY - image.extent.midY))
        return centered.composited(over: CIImage(color: .black).cropped(to: extent))
    }
}

extension SKTransition {

    /// Chess board transition, see `ChessboardTransitionFilter`.
    /// The total duration is `2 * snakeDuration + waitDuration`.
    /// - Parameters:
    ///   - snakeDuration: Seconds for the snakes to cover the whole screen (and again to uncover it)
    ///   - waitDuration: Seconds the screen stays fully covered, before uncovering
    ///   - scene: The scene being replaced, snapshotted to avoid a black first frame
    ///   - title: Optional title shown in large text while the screen is fully covered
    ///   - subtitle: Optional smaller line under the title
    /// - Returns: Transition
    static func chessboard(snakeDuration: TimeInterval,
                           waitDuration: TimeInterval,
                           from scene: SKScene? = nil,
                           title: String? = nil,
                           subtitle: String? = nil) -> SKTransition {
        let filter = ChessboardTransitionFilter()
        filter.inputSnakeDuration = NSNumber(value: snakeDuration)
        filter.inputWaitDuration = NSNumber(value: waitDuration)
        if let title, let scene {
            filter.inputOverlayImage = titleImage(title: title, subtitle: subtitle, size: scene.size)
        }
        if let scene, let view = scene.view, let texture = view.texture(from: scene) {
            filter.inputSnapshotImage = CIImage(cgImage: texture.cgImage())
        }

        // SpriteKit's own transition clock is irregular, and can end before its duration.
        // Give it a margin, so the filter's own clock always completes the animation.
        let transition = SKTransition(ciFilter: filter, duration: filter.totalDuration * 1.25)

        // the new scene stays paused until the transition has ended (SpriteKit's default),
        // so its own timers and animations only start once the transition has finished
        transition.pausesIncomingScene = true
        return transition
    }

    /// Title (and subtitle) centred on a transparent, scene sized image:
    /// white Rubik-Bold with a soft, 80% black outline, like OutlinedLabel
    private static func titleImage(title: String, subtitle: String?, size: CGSize) -> CIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
        let image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            func lines() -> [(String, CGFloat)] {
                [(title, 96)] + (subtitle.map { [($0, 46)] } ?? [])
            }
            let spacing: CGFloat = 18
            let fonts = lines().map { UIFont(name: "Rubik-Bold", size: $0.1) ?? .boldSystemFont(ofSize: $0.1) }
            let heights = fonts.map(\.lineHeight)
            var y = (size.height - heights.reduce(0, +) - spacing * CGFloat(heights.count - 1)) / 2
            for ((text, _), font) in zip(lines(), fonts) {
                let outline: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor(white: 0, alpha: 0.8),
                    .strokeColor: UIColor(white: 0, alpha: 0.8),
                    .strokeWidth: -2 * 2.2 / font.pointSize * 100,   // stroke is centred on the glyph edge: 2.2 pt outside
                ]
                let fill: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
                let width = (text as NSString).size(withAttributes: fill).width
                let origin = CGPoint(x: (size.width - width) / 2, y: y)
                (text as NSString).draw(at: origin, withAttributes: outline)
                (text as NSString).draw(at: origin, withAttributes: fill)
                y += font.lineHeight + spacing
            }
        }
        return image.cgImage.map { CIImage(cgImage: $0) }
    }
}

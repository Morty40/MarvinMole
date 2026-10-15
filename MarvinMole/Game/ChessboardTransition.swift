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
/// Then the process runs backwards to reveal the new scene.
///
/// SpriteKit sets `inputImage` (old scene), `inputTargetImage` (new scene) and
/// animates `inputTime` from 0 to 1, see `SKTransition(ciFilter:duration:)`.
final class ChessboardTransitionFilter: CIFilter {

    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputTargetImage: CIImage?
    @objc dynamic var inputTime: NSNumber = 0

    /// Snapshot of the old scene, taken before the transition starts.
    /// SpriteKit's own `inputImage` is still empty on the first frame, which shows as a black blink.
    @objc dynamic var inputSnapshotImage: CIImage?

    // board layout and look
    // (static, because SpriteKit copies the filter using the plain init())
    private static let columns = 8
    private static let rows = 6
    private static let colors = [CIColor(red: 148/255, green: 98/255, blue: 46/255),   // medium-light brown
                                 CIColor(red: 90/255, green: 55/255, blue: 20/255)]    // medium-dark brown, as the dirt walls

    /// Time each square flips to opaque, as a fraction of each half of the transition,
    /// indexed by `row * columns + column` (row 0 is the bottom row)
    private static let flipTimes: [Double] = {
        let steps = spiralSteps(columns: columns, rows: rows)

        // evenly spaced flip times, one per snake step
        // (the last step flips just before halfway, so the full board is shown briefly)
        let numberOfSteps = (steps.max() ?? 0) + 1
        return steps.map { Double($0 + 1) / Double(numberOfSteps + 1) }
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

        let time = min(max(inputTime.doubleValue, 0), 1)

        // first half: the board covers the old scene,
        // second half: the same sequence backwards, uncovering the new scene
        let extent = inputImage.extent
        let background = time < 0.5 ? oldScene(fitting: extent) ?? inputImage : inputTargetImage
        let progress = time < 0.5 ? time * 2 : (1 - time) * 2

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

        return board.composited(over: background).cropped(to: extent)
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

    /// Chess board transition, see `ChessboardTransitionFilter`
    /// - Parameters:
    ///   - duration: Duration of the whole transition (cover and uncover)
    ///   - scene: The scene being replaced, snapshotted to avoid a black first frame
    /// - Returns: Transition
    static func chessboard(withDuration duration: TimeInterval, from scene: SKScene? = nil) -> SKTransition {
        let filter = ChessboardTransitionFilter()
        if let scene, let view = scene.view, let texture = view.texture(from: scene) {
            filter.inputSnapshotImage = CIImage(cgImage: texture.cgImage())
        }
        return SKTransition(ciFilter: filter, duration: duration)
    }
}

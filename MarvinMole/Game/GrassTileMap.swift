//
//  GrassTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Grass around the map: random tiles from the Grass sheet (8 x 8 seamless tiles):
///  0-31 plain grass, 32-43 flowers, 44-51 pebbles, 52-57 rocks, 58-63 mud patches.
class GrassTileMap: SKTileMapNode {

    let grass = SKTexture(imageNamed: "Grass").split(columns: 8, rows: 8).map {
        SKTileGroup(tileDefinition: SKTileDefinition(texture: $0)) }

    override init() {
        super.init()
        tileSet = SKTileSet(tileGroups: grass)
    }

    /// Fill with random grass tiles. The layout is seeded, so the same seed always
    /// gives the same grass (e.g. the flood scene and the game scene match).
    func draw(seed: UInt64) {
        var state = seed &* 6364136223846793005 &+ 1442695040888963407
        func random(_ n: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(n))
        }
        // decorated tiles (flowers, pebbles, rocks, mud) are never next to each other,
        // not even diagonally; tiles are placed row by row, so only the neighbours to the
        // left and in the row before can already be decorated
        var decorated = Array(repeating: Array(repeating: false, count: numberOfColumns), count: numberOfRows)
        func hasDecoratedNeighbour(_ column: Int, _ row: Int) -> Bool {
            [(-1, 0), (-1, -1), (0, -1), (1, -1)].contains { dc, dr in
                let c = column + dc, r = row + dr
                return c >= 0 && c < numberOfColumns && r >= 0 && decorated[r][c]
            }
        }

        for row in 0 ..< numberOfRows {
            for column in 0 ..< numberOfColumns {
                // mostly plain grass, now and then a decorated tile
                let roll = hasDecoratedNeighbour(column, row) ? 0 : random(100)
                decorated[row][column] = roll >= 80
                let index = switch roll {
                case ..<80: random(32)              // plain grass
                case ..<89: 32 + random(12)         // flowers
                case ..<94: 44 + random(8)          // pebbles
                case ..<97: 52 + random(6)          // rocks
                default:    58 + random(6)          // mud
                }
                setTileGroup(grass[index], forColumn: column, row: row)
            }
        }
    }

    func clear() {
        fill(with: nil)
    }

    var size: (width: Int, height: Int) {
        get { (numberOfColumns, numberOfRows) }
        set { (numberOfColumns, numberOfRows) = newValue }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

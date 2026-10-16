//
//  GrassTileMap.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Grass around the map: random tiles from the Grass sheet (4 x 4 seamless tiles).
/// The first 9 tiles are plain grass, the last 7 have flowers, clover or a pebble.
class GrassTileMap: SKTileMapNode {

    let grass = SKTexture(imageNamed: "Grass").split(columns: 4, rows: 4).map {
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
        for row in 0 ..< numberOfRows {
            for column in 0 ..< numberOfColumns {
                // mostly plain grass, now and then a decorated tile
                let index = random(100) < 82 ? random(9) : 9 + random(7)
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

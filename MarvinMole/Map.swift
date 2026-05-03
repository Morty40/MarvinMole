//
//  Map.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation

/// Sokoban map representation
struct Map {

    enum StaticTile {
        case none
        case wall
        case goal
        case floor
        
        static func tileFrom(xsb symbol: String) -> StaticTile {
            switch symbol {
            case "#":
                return .wall
            case ".", "*", "+":
                return .goal
            case " ", "-", "_":
                return .floor
            default:
                return .none
            }
        }
    }

    enum ObjectTile {
        case none
        case hero
        case box
        
        static func tileFrom(xsb symbol: String) -> ObjectTile {
            switch symbol {
            case "@", "+":
                return .hero
            case "$", "*":
                return .box
            default:
                return .none
            }
        }
    }

    private var staticTiles: [[StaticTile]] = []
    private var objectTiles: [[ObjectTile]] = []

    var size: (width: Int, height: Int) {
        (staticTiles.map(\.count).max() ?? 0, staticTiles.count)
    }
    
    static func mapFromXsb(data: Data) -> Map? {
        if let string = String(bytes: data, encoding: .utf8) {
            return mapFromXsb(string: string)
        }
        return nil
    }
    
    static func mapFromXsb(string: String) -> Map? {
        
        // split by newline into list of strings
        let lines = string.split(whereSeparator: \.isNewline).map({ String($0) })
        
        // parse static tiles
        var staticTiles: [[StaticTile]] = []
        for l in lines {
            staticTiles.append( l.map({ StaticTile.tileFrom(xsb: String($0)) }) )
        }

        // TODO: fix the floors
        
        // parse object tiles
        var objectTiles: [[ObjectTile]] = []
        for l in lines {
            objectTiles.append( l.map({ ObjectTile.tileFrom(xsb: String($0)) }) )
        }

        return Map(staticTiles: staticTiles, objectTiles: objectTiles)
    }

    /// Returns the number of occurences of a specific type of tile
    /// - Parameter tile: Tile type
    /// - Returns: Number of occurences in map
    func count(of tile: StaticTile) -> Int {
        staticTiles.joined().count(where: { $0 == tile })
    }

    /// Returns the number of occurences of a specific type of tile
    /// - Parameter tile: Tile type
    /// - Returns: Number of occurences in map
    func count(of tile: ObjectTile) -> Int {
        objectTiles.joined().count(where: { $0 == tile })
    }

    /// Returns the tile at coordinate (x, y)
    /// - Parameters:
    ///   - x: X-coordinate
    ///   - y: Y-coordinate
    /// - Returns: Tile, or .none if outside the map
    func staticTileAt(x: Int, y: Int) -> StaticTile {
        if y >= 0, y < staticTiles.count {
            let row = staticTiles[y]
            if x >= 0, x < row.count {
                return row[x]
            }
        }
        return .none
    }
    
}

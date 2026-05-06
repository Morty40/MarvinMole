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
            case " ", "-", "_", "@", "$":
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
        
        // parse wall tiles
        var staticTiles: [[StaticTile]] = lines.map({ $0.map({
            StaticTile.tileFrom(xsb: String($0)) == .wall ? .wall : .none
        })})
        
        // parse object tiles
        let objectTiles: [[ObjectTile]] = lines.map({ $0.map({
            ObjectTile.tileFrom(xsb: String($0))
        })})
        
        // find coordinate of hero
        let heroY = objectTiles.firstIndex(where: { $0.contains(.hero) } )!
        let heroX = objectTiles[heroY].firstIndex(of: .hero)!

        func fillFloors(_ tiles: inout [[StaticTile]], x: Int, y: Int) {
            if y >= 0, y < tiles.count {
                if x >= 0, x < tiles[y].count {
                    if tiles[y][x] == .none {
                        tiles[y][x] = .floor
                        fillFloors(&tiles, x: x - 1, y: y)
                        fillFloors(&tiles, x: x + 1, y: y)
                        fillFloors(&tiles, x: x, y: y - 1)
                        fillFloors(&tiles, x: x, y: y + 1)
                    }
                }
            }
        }
        
        // recursive fill floors inside walls
        // (xsb data unfortunately has floors both inside and outside the walls)
        fillFloors(&staticTiles, x: heroX, y: heroY)
        
        let staticTiles2: [[StaticTile]] = lines.map({ $0.map({
            StaticTile.tileFrom(xsb: String($0))
        })})

        // parse static tiles again, ignore floors
        staticTiles = zip(staticTiles, staticTiles2).map({
            zip($0, $1).map({
                $1 != .floor ? $1 : $0
            })
        })
                                                              
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
    
    func objectsOf(type: ObjectTile) -> [(x: Int, y: Int)] {
        return [] // TODO: fix me
    }
    
}

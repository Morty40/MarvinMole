//
//  Map.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation

/// Sokoban map representation
struct Map {
    
    enum Tile: String {
        case box = "$"
        case boxOnGoal = "*"
        case floor = " " // xsb also allows "-" and "_"
        case goal = "."
        case man = "@"
        case manOnGoal = "+"
        case wall = "#"
    }
    
    var tiles: [[Tile]] = []
    var title: String? = nil
    var author: String? = nil

    var width: Int {
        tiles.map(\.count).max() ?? 0
    }
    
    var height: Int {
        tiles.count
    }
    
    var xsbRepresentation: Data {
        var lines: [String] = tiles.map { $0.map(\.rawValue).joined() }
        if let title = title {
            lines.append("Title: \(title)")
        }
        if let author = author {
            lines.append("Author: \(author)")
        }
        return Data(lines.joined(separator: "\n").utf8)
    }
    
    func printXsb() {
        for row in tiles {
            print(row.map(\.rawValue).joined())
        }
    }
    
    // TODO: fix me
    static func mapFromXsb(data: Data) -> Map? {
        // convert data to utf8 text
        if let text = String(bytes: data, encoding: .utf8) {
            
            // parse data into list of strings
            let lines = text.split(whereSeparator: \.isNewline).map({ String($0) })

            var tiles: [[Tile]] = []
            
            for l in lines {
                tiles.append( l.map({ Tile(rawValue: String($0))! }) )
            }
            
            return Map(tiles: tiles, title: nil, author: nil)
        }

        return nil
    }

    /// Returns the number of occurences of a specific type of tile
    /// - Parameter tile: Tile type
    /// - Returns: Number of occurences in map
    func count(of tile: Tile) -> Int {
        tiles.joined().count(where: { $0 == tile })
    }

    /// Returns the tile at coordinate (x, y)
    /// - Parameters:
    ///   - x: X-coordinate
    ///   - y: Y-coordinate
    /// - Returns: Tile, or nil if outside the map
    func tileAt(x: Int, y: Int) -> Tile? {
        if y >= 0, y < tiles.count {
            let row = tiles[y]
            if x >= 0, x < row.count {
                return row[x]
            }
        }
        return nil
    }
    
}

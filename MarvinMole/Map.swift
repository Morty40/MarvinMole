//
//  Map.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation

/// Sokoban map representation
class Map {
    
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
        
        var isCollidable: Bool {
            [.wall].contains(self)
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
    
    // Sokoban solution LURD format
    enum Move: String {
        case walkLeft  = "l"
        case walkUp    = "u"
        case walkRight = "r"
        case walkDown  = "d"
        case pushLeft  = "L"
        case pushUp    = "U"
        case pushRight = "R"
        case pushDown  = "D"
        
        var isPush: Bool {
            [.pushLeft, .pushRight, .pushUp, .pushDown].contains(self)
        }
    }
    
    private var staticTiles: [[StaticTile]] = []
    private var objectTiles: [[ObjectTile]] = []
    private var completedMoves: [Move] = []
    
    init(staticTiles: [[StaticTile]], objectTiles: [[ObjectTile]]) {
        self.staticTiles = staticTiles
        self.objectTiles = objectTiles
        self.completedMoves = []
    }
    
    /// Map size
    var size: (width: Int, height: Int) {
        (staticTiles.map(\.count).max() ?? 0, staticTiles.count)
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
    
    /// Returns the static tile at coordinate (x, y)
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
    
    /// Returns the object tile at coordinate (x, y)
    /// - Parameters:
    ///   - x: X-coordinate
    ///   - y: Y-coordinate
    /// - Returns: Tile, or .none if outside the map
    func objectTileAt(x: Int, y: Int) -> ObjectTile {
        if y >= 0, y < objectTiles.count {
            let row = objectTiles[y]
            if x >= 0, x < row.count {
                return row[x]
            }
        }
        return .none
    }
    
    /// Put object tile of type at coordinate (x, y)
    /// - Parameters:
    ///   - x: X coordinate
    ///   - y: Y coordinate
    ///   - tile: Object tile
    func putObjectTileAt(x: Int, y: Int, _ tile: ObjectTile) {
        objectTiles[y][x] = tile
    }
    
    var heroPosition: (x: Int, y: Int)? {
        if let heroY = objectTiles.firstIndex(where: { $0.contains(.hero) } ),
           let heroX = objectTiles[heroY].firstIndex(of: .hero) {
            return (heroX, heroY)
        }
        return nil
    }
    
    var boxPositions: [(x: Int, y: Int)] {
        var positions: [(x: Int, y: Int)] = []
        
        for (y, row) in objectTiles.enumerated() {
            for (x, tile) in row.enumerated() where tile == .box {
                positions.append((x, y))
            }
        }
        
        return positions
    }
    
    var legalMoves: [Move] {
        var moves: [Move] = []
        
        if let (x, y) = heroPosition {
            
            // left
            if !staticTileAt(x: x-1, y: y).isCollidable &&
                objectTileAt(x: x-1, y: y) == .none {
                moves.append(.walkLeft)
            } else if !staticTileAt(x: x-1, y: y).isCollidable &&
                        objectTileAt(x: x-1, y: y) == .box &&
                        !staticTileAt(x: x-2, y: y).isCollidable &&
                        objectTileAt(x: x-2, y: y) == .none {
                moves.append(.pushLeft)
            }

            // up
            if !staticTileAt(x: x, y: y-1).isCollidable &&
                objectTileAt(x: x, y: y-1) == .none {
                moves.append(.walkUp)
            } else if !staticTileAt(x: x, y: y-1).isCollidable &&
                        objectTileAt(x: x, y: y-1) == .box &&
                        !staticTileAt(x: x, y: y-2).isCollidable &&
                        objectTileAt(x: x, y: y-2) == .none {
                moves.append(.pushUp)
            }

            // right
            if !staticTileAt(x: x+1, y: y).isCollidable &&
                objectTileAt(x: x+1, y: y) == .none {
                moves.append(.walkRight)
            } else if !staticTileAt(x: x+1, y: y).isCollidable &&
                        objectTileAt(x: x+1, y: y) == .box &&
                        !staticTileAt(x: x+2, y: y).isCollidable &&
                        objectTileAt(x: x+2, y: y) == .none {
                moves.append(.pushRight)
            }

            // down
            if !staticTileAt(x: x, y: y+1).isCollidable &&
                objectTileAt(x: x, y: y+1) == .none {
                moves.append(.walkDown)
            } else if !staticTileAt(x: x, y: y+1).isCollidable &&
                        objectTileAt(x: x, y: y+1) == .box &&
                        !staticTileAt(x: x, y: y+2).isCollidable &&
                        objectTileAt(x: x, y: y+2) == .none {
                moves.append(.pushDown)
            }
        }
        
        return moves
    }
    
    var numberOfMoves: Int {
        completedMoves.count
    }
    
    var numberOfPushes: Int {
        completedMoves.count(where: \.isPush)
    }

    func moveObjectTile(from: (x: Int, y: Int), to: (x: Int, y: Int)) {
        let objectTile = objectTileAt(x: from.x, y: from.y)
        putObjectTileAt(x: from.x, y: from.y, .none)
        putObjectTileAt(x: to.x, y: to.y, objectTile)
    }
    
    @discardableResult
    func doNextMove(_ move: Move) -> Bool {
        if legalMoves.contains(move), let heroPosition = heroPosition {
            
            let heroX = heroPosition.x
            let heroY = heroPosition.y
            
            switch move {
            case .walkLeft:
                moveObjectTile(from: heroPosition, to: (heroX-1, heroY))
            case .walkUp:
                moveObjectTile(from: heroPosition, to: (heroX, heroY-1))
            case .walkRight:
                moveObjectTile(from: heroPosition, to: (heroX+1, heroY))
            case .walkDown:
                moveObjectTile(from: heroPosition, to: (heroX, heroY+1))
            case .pushLeft:
                moveObjectTile(from: (heroX-1, heroY), to: (heroX-2, heroY))
                moveObjectTile(from: heroPosition, to: (heroX-1, heroY))
            case .pushUp:
                moveObjectTile(from: (heroX, heroY-1), to: (heroX, heroY-2))
                moveObjectTile(from: heroPosition, to: (heroX, heroY-1))
            case .pushRight:
                moveObjectTile(from: (heroX+1, heroY), to: (heroX+2, heroY))
                moveObjectTile(from: heroPosition, to: (heroX+1, heroY))
            case .pushDown:
                moveObjectTile(from: (heroX, heroY+1), to: (heroX, heroY+2))
                moveObjectTile(from: heroPosition, to: (heroX, heroY+1))
            }
            
            completedMoves.append(move)
            return true
        }
        return false
    }
    
    @discardableResult
    func undoLastMove() -> Bool {
        if let move = completedMoves.popLast(), let heroPosition = heroPosition {
            
            let heroX = heroPosition.x
            let heroY = heroPosition.y
            
            switch move {
            case .walkLeft:
                moveObjectTile(from: heroPosition, to: (heroX+1, heroY))
            case .walkUp:
                moveObjectTile(from: heroPosition, to: (heroX, heroY+1))
            case .walkRight:
                moveObjectTile(from: heroPosition, to: (heroX-1, heroY))
            case .walkDown:
                moveObjectTile(from: heroPosition, to: (heroX, heroY-1))
            case .pushLeft:
                moveObjectTile(from: (heroX+1, heroY), to: (heroX+2, heroY))
                moveObjectTile(from: heroPosition, to: (heroX+1, heroY))
            case .pushUp:
                moveObjectTile(from: (heroX, heroY+1), to: (heroX, heroY+2))
                moveObjectTile(from: heroPosition, to: (heroX, heroY+1))
            case .pushRight:
                moveObjectTile(from: (heroX-1, heroY), to: (heroX-2, heroY))
                moveObjectTile(from: heroPosition, to: (heroX-1, heroY))
            case .pushDown:
                moveObjectTile(from: (heroX, heroY-1), to: (heroX, heroY-2))
                moveObjectTile(from: heroPosition, to: (heroX, heroY-1))
            }
            
            return true
        }
        return false
    }
    
    /// Check if all goals have a box on top
    var isCompleted: Bool {
        for (y, row) in staticTiles.enumerated() {
            for (x, tile) in row.enumerated() where tile == .goal {
                
                if objectTileAt(x: x, y: y) != .box {
                    // no box on top of this goal, the map is not completed
                    return false
                }
            }
        }
        
        // all goals have a box on top, the map is completed
        return true
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
        
        // find the hero coordinate
        var heroX: Int? = nil
        var heroY: Int? = nil
        if let y = objectTiles.firstIndex(where: { $0.contains(.hero) } ) {
            if let x = objectTiles[y].firstIndex(of: .hero) {
                heroX = x
                heroY = y
            }
        }
        
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
        
        // recursive fill floors inside walls starting from hero
        // (xsb data unfortunately has floors both inside and outside the walls)
        if let heroX = heroX, let heroY = heroY {
            fillFloors(&staticTiles, x: heroX, y: heroY)
        }
        
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
    
    static func empty() -> Map {
        return Map(staticTiles: [], objectTiles: [])
    }
}

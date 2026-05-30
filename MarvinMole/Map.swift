//
//  Map.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation

/// Sokoban map representation
class Map {
    
    /// Static tile types
    enum Tile {
        case void
        case wall
        case floor
        case floorGoal
        
        /// Convert symbol to tile, using .xsb notation
        /// - Parameter symbol: map symbol
        /// - Returns: Tile
        static func tileFrom(symbol: String) -> Tile {
            switch symbol {
            case "#":
                return .wall
            case " ", "-", "_", "@", "$":
                return .floor
            case ".", "*", "+":
                return .floorGoal
            default:
                return .void
            }
        }
        
        var isVoid: Bool {
            self == .void
        }

        var isWall: Bool {
            self == .wall
        }

        var isFloor: Bool {
            [.floor, .floorGoal].contains(self)
        }

    }
    
    /// Movable object types
    enum ObjectType {
        case hero
        case box
        
        static func typeFrom(xsb symbol: String) -> ObjectType? {
            switch symbol {
            case "@", "+":
                return .hero
            case "$", "*":
                return .box
            default:
                return nil
            }
        }
    }
    
    struct Object {
        var position: (x: Int, y: Int)
        var type: ObjectType
        var id: Int
    }
    
    /// Move types, using Sokoban solution LURD notation
    enum Move: String {
        case walkLeft  = "l"
        case walkUp    = "u"
        case walkRight = "r"
        case walkDown  = "d"
        case pushLeft  = "L"
        case pushUp    = "U"
        case pushRight = "R"
        case pushDown  = "D"
        
        var isLeft: Bool {
            [.walkLeft, .pushLeft].contains(self)
        }
        
        var isUp: Bool {
            [.walkUp, .pushUp].contains(self)
        }
        
        var isRight: Bool {
            [.walkRight, .pushRight].contains(self)
        }
        
        var isDown: Bool {
            [.walkDown, .pushDown].contains(self)
        }
        
        var isPush: Bool {
            [.pushLeft, .pushRight, .pushUp, .pushDown].contains(self)
        }
    }
    
    var title: String? = nil
    private var tiles: [[Tile]] = []
    private var objects: [Object] = []
    private var moves: [Move] = []
    
    init(title: String?, tiles: [[Tile]], objects: [Object]) {
        self.title = title
        self.tiles = tiles
        self.objects = objects
        self.moves = []
    }
    
    /// Map size
    var size: (width: Int, height: Int) {
        (tiles.map(\.count).max() ?? 0, tiles.count)
    }
    
    /// Returns the number of occurences of a specific tile
    /// - Parameter tile: Tile type
    /// - Returns: Number of occurences in map
    func count(of tile: Tile) -> Int {
        tiles.joined().count(where: { $0 == tile })
    }
    
    /// Returns the number of occurences of a specific object type
    /// - Parameter type: Object type
    /// - Returns: Number of occurences in map
    func count(of type: ObjectType) -> Int {
        objects.count(where: { $0.type == type })
    }
    
    /// Returns the tile at coordinate (x, y) or .void if outside the map
    /// - Parameters:
    ///   - x: X-coordinate
    ///   - y: Y-coordinate
    /// - Returns: Tile or .void if outside the map
    func tileAt(x: Int, y: Int) -> Tile {
        if y >= 0, y < tiles.count {
            let row = tiles[y]
            if x >= 0, x < row.count {
                return row[x]
            }
        }
        return .void
    }
    
    /// Returns the object at coordinate (x, y) or nil if there is no object
    /// - Parameters:
    ///   - x: X-coordinate
    ///   - y: Y-coordinate
    /// - Returns: Object or nil
    func objectAt(x: Int, y: Int) -> Object? {
        objects.first(where: { $0.position.x == x && $0.position.y == y })
    }
    
    /// Check if there is an object at coordinate (x, y)
    /// - Parameters:
    ///   - x: X-coordinate
    ///   - y: Y-coordinate
    /// - Returns: True if there is an object, else false
    func isObjectAt(x: Int, y: Int) -> Bool {
        objectAt(x: x, y: y) != nil
    }
    
    /// If there is an object at coordinate (x, y), it wll be removed
    /// - Parameters:
    ///   - x: X-coordinate
    ///   - y: Y-coordinate
    func removeObjectAt(x: Int, y: Int) {
        objects = objects.filter({ $0.position != (x, y) })
    }
    
    func putObjectAt(x: Int, y: Int, type: ObjectType) {
        removeObjectAt(x: x, y: y)
        let n = count(of: type)
        let object = Object(position: (x, y), type: type, id: n)
        objects.append(object)
    }
    
    /// Current position of the hero
    var heroPosition: (x: Int, y: Int)? {
        if let hero = objects.first(where: { $0.type == .hero }) {
            return hero.position
        }
        return nil
    }
    
    /// Current legal moves
    var legalMoves: [Move] {
        var moves: [Move] = []
        
        if let (x, y) = heroPosition {
            
            // left
            if !tileAt(x: x-1, y: y).isWall &&
                !isObjectAt(x: x-1, y: y) {
                moves.append(.walkLeft)
            } else if !tileAt(x: x-1, y: y).isWall &&
                        objectAt(x: x-1, y: y)?.type == .box &&
                        !tileAt(x: x-2, y: y).isWall &&
                        !isObjectAt(x: x-2, y: y) {
                moves.append(.pushLeft)
            }
            
            // up
            if !tileAt(x: x, y: y-1).isWall &&
                !isObjectAt(x: x, y: y-1) {
                moves.append(.walkUp)
            } else if !tileAt(x: x, y: y-1).isWall &&
                        objectAt(x: x, y: y-1)?.type == .box &&
                        !tileAt(x: x, y: y-2).isWall &&
                        !isObjectAt(x: x, y: y-2) {
                moves.append(.pushUp)
            }
            
            // right
            if !tileAt(x: x+1, y: y).isWall &&
                !isObjectAt(x: x+1, y: y) {
                moves.append(.walkRight)
            } else if !tileAt(x: x+1, y: y).isWall &&
                        objectAt(x: x+1, y: y)?.type == .box &&
                        !tileAt(x: x+2, y: y).isWall &&
                        !isObjectAt(x: x+2, y: y) {
                moves.append(.pushRight)
            }
            
            // down
            if !tileAt(x: x, y: y+1).isWall &&
                !isObjectAt(x: x, y: y+1) {
                moves.append(.walkDown)
            } else if !tileAt(x: x, y: y+1).isWall &&
                        objectAt(x: x, y: y+1)?.type == .box &&
                        !tileAt(x: x, y: y+2).isWall &&
                        !isObjectAt(x: x, y: y+2) {
                moves.append(.pushDown)
            }
        }
        
        return moves
    }
    
    /// Check if all goals have a box on top
    var isCompleted: Bool {
        for (y, row) in tiles.enumerated() {
            for (x, tile) in row.enumerated() where tile == .floorGoal {
                
                if objectAt(x: x, y: y)?.type != .box {
                    // no box on top of this goal, the map is not completed
                    return false
                }
            }
        }
        
        // all goals have a box on top, the map is completed
        return true
    }

    func objectsOfType(_ type: ObjectType) -> [Object] {
        objects.filter({ $0.type == type })
    }
    
    private func moveObject(from: (x: Int, y: Int),
                            to: (x: Int, y: Int),
                            movedObjects: inout [Object]) {
        
        if let object = objectAt(x: from.x, y: from.y) {
            removeObjectAt(x: from.x, y: from.y)
            let movedObject = Object(position: to, type: object.type, id: object.id)
            objects.append(movedObject)
            movedObjects.append(movedObject)
        }
    }
    
    @discardableResult
    func doNextMove(_ move: Move) -> [Object] {
        var movedObjects: [Object] = []
        
        if legalMoves.contains(move), let heroPosition = heroPosition {
            
            let (x, y) = heroPosition
            
            switch move {
            case .walkLeft:
                moveObject(from: (x, y), to: (x-1, y), movedObjects: &movedObjects)
            case .walkUp:
                moveObject(from: (x, y), to: (x, y-1), movedObjects: &movedObjects)
            case .walkRight:
                moveObject(from: (x, y), to: (x+1, y), movedObjects: &movedObjects)
            case .walkDown:
                moveObject(from: (x, y), to: (x, y+1), movedObjects: &movedObjects)
            case .pushLeft:
                moveObject(from: (x-1, y), to: (x-2, y), movedObjects: &movedObjects)
                moveObject(from: (x, y), to: (x-1, y), movedObjects: &movedObjects)
            case .pushUp:
                moveObject(from: (x, y-1), to: (x, y-2), movedObjects: &movedObjects)
                moveObject(from: (x, y), to: (x, y-1), movedObjects: &movedObjects)
            case .pushRight:
                moveObject(from: (x+1, y), to: (x+2, y), movedObjects: &movedObjects)
                moveObject(from: (x, y), to: (x+1, y), movedObjects: &movedObjects)
            case .pushDown:
                moveObject(from: (x, y+1), to: (x, y+2), movedObjects: &movedObjects)
                moveObject(from: (x, y), to: (x, y+1), movedObjects: &movedObjects)
            }
            
            moves.append(move)
        }
        
        return movedObjects
    }
    
    @discardableResult
    func undoLastMove() -> [Object] {
        var movedObjects: [Object] = []

        if let move = moves.popLast(), let heroPosition = heroPosition {
            
            let (x, y) = heroPosition
            
            switch move {
            case .walkLeft:
                moveObject(from: (x, y), to: (x+1, y), movedObjects: &movedObjects)
            case .walkUp:
                moveObject(from: (x, y), to: (x, y+1), movedObjects: &movedObjects)
            case .walkRight:
                moveObject(from: (x, y), to: (x-1, y), movedObjects: &movedObjects)
            case .walkDown:
                moveObject(from: (x, y), to: (x, y-1), movedObjects: &movedObjects)
            case .pushLeft:
                moveObject(from: (x, y), to: (x+1, y), movedObjects: &movedObjects)
                moveObject(from: (x-1, y), to: (x, y), movedObjects: &movedObjects)
            case .pushUp:
                moveObject(from: (x, y), to: (x, y+1), movedObjects: &movedObjects)
                moveObject(from: (x, y-1), to: (x, y), movedObjects: &movedObjects)
            case .pushRight:
                moveObject(from: (x, y), to: (x-1, y), movedObjects: &movedObjects)
                moveObject(from: (x+1, y), to: (x, y), movedObjects: &movedObjects)
            case .pushDown:
                moveObject(from: (x, y), to: (x, y-1), movedObjects: &movedObjects)
                moveObject(from: (x, y+1), to: (x, y), movedObjects: &movedObjects)
            }
        }

        return movedObjects
    }
    
    /// Number of completed moves, walk and box push
    var numberOfMoves: Int {
        moves.count
    }
    
    /// Number of completed moves that were box pushes
    var numberOfPushes: Int {
        moves.count(where: \.isPush)
    }
    
    static func mapFromXsb(data: Data) -> Map? {
        if let string = String(bytes: data, encoding: .utf8) {
            return mapFromXsb(string: string)
        }
        return nil
    }
    
    static func mapFromXsb(string: String) -> Map? {
        
        // split by newline into list of strings
        var lines = string.split(whereSeparator: \.isNewline).map({ String($0) })
        
        // parse map title
        var title: String? = nil
        if let line = lines.first(where: { $0.hasPrefix("Title:") }) {
            title = String(line.split(separator: ":").last ?? "")
        }
        
        // TODO: fix me
        lines = lines.filter({ !$0.hasPrefix("Title:") })
        
        // parse wall tiles
        var tiles: [[Tile]] = lines.map({ $0.map({
            Tile.tileFrom(symbol: String($0)).isWall ? .wall : .void
        })})
        
        // parse object tiles
        var objects: [Object] = []
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                if let type = ObjectType.typeFrom(xsb: String(char)) {
                    objects.append(Object(position: (x, y),
                                          type: type,
                                          id: objects.count))
                }
            }
        }

        // find the hero coordinate
        var heroX: Int? = nil
        var heroY: Int? = nil
        if let hero = objects.first(where: { $0.type == .hero }) {
            heroX = hero.position.x
            heroY = hero.position.y
        }
        
        func fillFloors(_ tiles: inout [[Tile]], x: Int, y: Int) {
            if y >= 0, y < tiles.count {
                if x >= 0, x < tiles[y].count {
                    if tiles[y][x].isVoid {
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
            fillFloors(&tiles, x: heroX, y: heroY)
        }
        
        let tiles2: [[Tile]] = lines.map({ $0.map({
            Tile.tileFrom(symbol: String($0))
        })})
        
        // parse static tiles again, ignore floors
        tiles = zip(tiles, tiles2).map({
            zip($0, $1).map({
                $1 != .floor ? $1 : $0
            })
        })
        
        return Map(title: title, tiles: tiles, objects: objects)
    }
    
    static var empty: Map {
        Map(title: nil, tiles: [], objects: [])
    }
}

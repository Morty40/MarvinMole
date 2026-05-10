//
//  MapTests.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Testing
@testable import MarvinMole

private let smallXsb = """
 #####
#@$.*#
######
"""

private let largeXsb = """
    #####
    #   #
    #$  #
  ###  $##
  #  $ $ #
### # ## #   ######
#   # ## #####  ..#
# $  $          ..#
##### ### #@##  ..#
    #     #########
    #######    
"""

struct MapTests {
    let smallMap = Map.mapFromXsb(string: smallXsb)!
    let largeMap = Map.mapFromXsb(string: largeXsb)!

    @Test func size() async throws {
        let emptyMap = await Map.empty()
        #expect(emptyMap.size == (0, 0))
        
        let otherMap = await Map.mapFromXsb(string: largeXsb)!
        #expect(otherMap.size == (19, 11))
    }

    @Test func count() async throws {
        let emptyMap = await Map.empty()
        #expect(emptyMap.count(of: .wall) == 0)
        #expect(emptyMap.count(of: .goal) == 0)
        #expect(emptyMap.count(of: .hero) == 0)
        #expect(emptyMap.count(of: .box) == 0)

        #expect(smallMap.count(of: .wall) == 13)
        #expect(smallMap.count(of: .goal) == 2)
        #expect(smallMap.count(of: .hero) == 1)
        #expect(smallMap.count(of: .box) == 2)

        #expect(largeMap.count(of: .wall) == 70)
        #expect(largeMap.count(of: .goal) == 6)
        #expect(largeMap.count(of: .hero) == 1)
        #expect(largeMap.count(of: .box) == 6)
    }

    @Test func tileAt() async throws {
        let emptyMap = await Map.empty()
        #expect(emptyMap.staticTileAt(x: 0, y: 0) == .none)
        #expect(emptyMap.staticTileAt(x: 1, y: 1) == .none)
        #expect(emptyMap.objectTileAt(x: 0, y: 0) == .none)
        #expect(emptyMap.objectTileAt(x: 1, y: 1) == .none)

        let smallMap = await Map.mapFromXsb(string: smallXsb)!
        #expect(smallMap.staticTileAt(x: 0, y: 0) == .none)
        #expect(smallMap.staticTileAt(x: 1, y: 0) == .wall)
        #expect(smallMap.staticTileAt(x: 1, y: 1) == .floor)
        #expect(smallMap.objectTileAt(x: 1, y: 1) == .hero)
        #expect(smallMap.objectTileAt(x: 2, y: 1) == .box)

        let largeMap = await Map.mapFromXsb(string: largeXsb)!
        #expect(largeMap.staticTileAt(x: 0, y: 0) == .none)
        #expect(largeMap.staticTileAt(x: 4, y: 0) == .wall)
        #expect(largeMap.staticTileAt(x: 5, y: 1) == .floor)
        #expect(largeMap.objectTileAt(x: 11, y: 8) == .hero)
        #expect(largeMap.objectTileAt(x: 5, y: 2) == .box)
    }
    
    @Test func putObjectTileAt() async throws {
        let map = await Map.mapFromXsb(string: smallXsb)!
        #expect(map.objectTileAt(x: 2, y: 1) == .box)
        #expect(map.count(of: .hero) == 1)
        
        await map.putObjectTileAt(x: 2, y: 1, .hero)
        #expect(map.objectTileAt(x: 2, y: 1) == .hero)
        #expect(map.count(of: .hero) == 2)
    }
    
    @Test func legalMoves() async throws {
        let emptyMap = await Map.empty()
        #expect(emptyMap.legalMoves.isEmpty)
                
        let largeMap = await Map.mapFromXsb(string: largeXsb)!
        #expect(largeMap.heroPosition! == (x: 11, y: 8))
        #expect(largeMap.legalMoves == [.walkUp])
        
        await largeMap.doNextMove(.walkUp)
        #expect(largeMap.heroPosition! == (x: 11, y: 7))
        #expect(largeMap.legalMoves == [.walkLeft, .walkRight, .walkDown])

        await largeMap.doNextMove(.walkLeft)
        #expect(largeMap.heroPosition! == (x: 10, y: 7))
        #expect(largeMap.legalMoves == [.walkLeft, .walkRight])

        await largeMap.doNextMove(.walkLeft)
        #expect(largeMap.heroPosition! == (x: 9, y: 7))
        #expect(largeMap.legalMoves == [.walkLeft, .walkRight, .walkDown])

        await largeMap.doNextMove(.walkLeft)
        #expect(largeMap.heroPosition! == (x: 8, y: 7))
        #expect(largeMap.legalMoves == [.walkLeft, .walkUp, .walkRight])

        await largeMap.doNextMove(.walkLeft)
        #expect(largeMap.heroPosition! == (x: 7, y: 7))
        #expect(largeMap.legalMoves == [.walkLeft, .walkRight])

        await largeMap.doNextMove(.walkLeft)
        #expect(largeMap.heroPosition! == (x: 6, y: 7))
        #expect(largeMap.legalMoves == [.pushLeft, .walkRight])

        await largeMap.doNextMove(.pushLeft)
        #expect(largeMap.heroPosition! == (x: 5, y: 7))
        #expect(largeMap.legalMoves == [.pushLeft, .walkUp, .walkRight, .walkDown])
    }

    @Test func completed() async throws {
        let emptyMap = await Map.empty()
        #expect(emptyMap.isCompleted == true)
        
        #expect(smallMap.isCompleted == false)
        await smallMap.doNextMove(.pushRight)
        // TODO: #expect(smallMap.isCompleted == true)

        #expect(largeMap.isCompleted == false)
    }

}

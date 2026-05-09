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
    let emptyMap = Map.mapFromXsb(string: "")!
    let smallMap = Map.mapFromXsb(string: smallXsb)!

    @Test func tiles() async throws {
        #expect(emptyMap.staticTileAt(x: 0, y: 0) == .none)
        #expect(emptyMap.staticTileAt(x: 1, y: 1) == .none)
        #expect(emptyMap.objectTileAt(x: 0, y: 0) == .none)
        #expect(emptyMap.objectTileAt(x: 1, y: 1) == .none)

        #expect(smallMap.staticTileAt(x: 0, y: 0) == .none)
        #expect(smallMap.staticTileAt(x: 4, y: 0) == .wall)
        #expect(smallMap.staticTileAt(x: 5, y: 1) == .floor)
        #expect(smallMap.objectTileAt(x: 5, y: 2) == .box)
    }

    @Test func size() async throws {
        #expect(emptyMap.size == (0, 0))
        #expect(smallMap.size == (19, 11))
    }

    @Test func count() async throws {
        #expect(emptyMap.count(of: .wall) == 0)
        #expect(emptyMap.count(of: .goal) == 0)
        #expect(emptyMap.count(of: .hero) == 0)
        #expect(emptyMap.count(of: .box) == 0)

        #expect(smallMap.count(of: .wall) == 70)
        #expect(smallMap.count(of: .goal) == 6)
        #expect(smallMap.count(of: .hero) == 1)
        #expect(smallMap.count(of: .box) == 6)
    }
    
    @Test func legalMoves() async throws {
        #expect(emptyMap.legalMoves == [])
        #expect(smallMap.legalMoves == [.walkUp])
    }

    @Test func completed() async throws {
        #expect(emptyMap.isCompleted == true)
        #expect(smallMap.isCompleted == false)
    }

}

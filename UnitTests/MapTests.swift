//
//  MapTests.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation
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

        #expect(smallMap.staticTileAt(x: 0, y: 0) == .floor)
        #expect(smallMap.staticTileAt(x: 4, y: 0) == .wall)
    }

    @Test func size() async throws {
        #expect(emptyMap.size == (0, 0))
        #expect(smallMap.size == (19, 11))
    }

    @Test func count() async throws {
        #expect(emptyMap.count(of: .wall) == 0)
        #expect(emptyMap.count(of: .goal) == 0)
        #expect(smallMap.count(of: .hero) == 0)
        #expect(smallMap.count(of: .box) == 0)

        #expect(smallMap.count(of: .wall) == 70)
        #expect(smallMap.count(of: .goal) == 6)
        #expect(smallMap.count(of: .hero) == 1)
        #expect(smallMap.count(of: .box) == 6)
    }

}

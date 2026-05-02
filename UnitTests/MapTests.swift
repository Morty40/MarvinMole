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
    let emptyMap = Map.mapFromXsb(data: "".data(using: .utf8)!)!
    let smallMap = Map.mapFromXsb(data: smallXsb.data(using: .utf8)!)!

    @Test func tiles() async throws {
        #expect(emptyMap.tileAt(x: 0, y: 0) == nil)
        #expect(emptyMap.tileAt(x: 1, y: 1) == nil)

        #expect(smallMap.tileAt(x: 0, y: 0) == .floor)
        #expect(smallMap.tileAt(x: 4, y: 0) == .wall)
    }

    @Test func size() async throws {
        #expect(emptyMap.width == 0)
        #expect(emptyMap.height == 0)

        #expect(smallMap.width == 19)
        #expect(smallMap.height == 11)
    }

    @Test func count() async throws {
        #expect(emptyMap.count(of: .wall) == 0)
        #expect(emptyMap.count(of: .goal) == 0)

        #expect(smallMap.count(of: .wall) == 70)
        #expect(smallMap.count(of: .goal) == 6)
    }

}

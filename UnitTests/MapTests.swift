//
//  MapTests.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Testing
@testable import MarvinMole

private let testXsb = """
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

    @Test func size() async throws {
        let emptyMap = await Map.empty
        #expect(emptyMap.size == (0, 0))
        
        let otherMap = await Map.mapFromXsb(string: testXsb)!
        #expect(otherMap.size == (19, 11))
    }

    @Test func count() async throws {
        let emptyMap = await Map.empty
        #expect(emptyMap.count(of: .wall) == 0)
        #expect(emptyMap.count(of: .floorGoal) == 0)
        #expect(emptyMap.count(of: .floor) == 0)
        #expect(emptyMap.count(of: .hero) == 0)
        #expect(emptyMap.count(of: .box) == 0)

        let testMap = await Map.mapFromXsb(string: testXsb)!
        #expect(testMap.count(of: .wall) == 70)
        #expect(testMap.count(of: .floorGoal) == 6)
        #expect(testMap.count(of: .floor) == 50)
        #expect(testMap.count(of: .hero) == 1)
        #expect(testMap.count(of: .box) == 6)
    }

    @Test func tileAt() async throws {
        let emptyMap = await Map.empty
        #expect(emptyMap.tileAt(x: 0, y: 0).isVoid)
        #expect(emptyMap.tileAt(x: 1, y: 1).isVoid)

        let testMap = await Map.mapFromXsb(string: testXsb)!
        #expect(testMap.tileAt(x: 0, y: 0).isVoid)
        #expect(testMap.tileAt(x: 4, y: 0).isWall)
        #expect(testMap.tileAt(x: 17, y: 6) == .floorGoal)
        #expect(testMap.tileAt(x: 5, y: 1) == .floor)
    }

    @Test func objectAt() async throws {
        let emptyMap = await Map.empty
        await #expect(emptyMap.objectAt(x: 0, y: 0)?.type == nil)
        await #expect(emptyMap.objectAt(x: 1, y: 1)?.type == nil)

        let testMap = await Map.mapFromXsb(string: testXsb)!
        await #expect(testMap.objectAt(x: 0, y: 0)?.type == nil)
        await #expect(testMap.objectAt(x: 11, y: 8)?.type == .hero)
        await #expect(testMap.objectAt(x: 5, y: 2)?.type == .box)
    }

    @Test func isObjectAt() async throws {
        let emptyMap = await Map.empty
        await #expect(emptyMap.isObjectAt(x: 0, y: 0) == false)
        await #expect(emptyMap.isObjectAt(x: 1, y: 1) == false)

        let testMap = await Map.mapFromXsb(string: testXsb)!
        await #expect(testMap.isObjectAt(x: 0, y: 0) == false)
        await #expect(testMap.isObjectAt(x: 11, y: 8) == true)
        await #expect(testMap.isObjectAt(x: 5, y: 2) == true)
    }

    @Test func removeObjectAt() async throws {
        let testMap = await Map.mapFromXsb(string: testXsb)!
        await #expect(testMap.isObjectAt(x: 11, y: 8) == true)
        await testMap.removeObjectAt(x: 11, y: 8)
        await #expect(testMap.isObjectAt(x: 11, y: 8) == false)
    }

    @Test func heroPosition() async throws {
        let emptyMap = await Map.empty
        #expect(emptyMap.heroPosition == nil)

        let testMap = await Map.mapFromXsb(string: testXsb)!
        #expect(testMap.heroPosition! == (x: 11, y: 8))
    }

    @Test func legalMoves() async throws {
        let emptyMap = await Map.empty
        #expect(emptyMap.legalMoves.isEmpty)
                
        let testMap = await Map.mapFromXsb(string: testXsb)!
        #expect(testMap.heroPosition! == (x: 11, y: 8))
        #expect(testMap.legalMoves == [.walkUp])
        
        await testMap.doNextMove(.walkUp)
        #expect(testMap.heroPosition! == (x: 11, y: 7))
        #expect(testMap.legalMoves == [.walkLeft, .walkRight, .walkDown])

        await testMap.doNextMove(.walkLeft)
        #expect(testMap.heroPosition! == (x: 10, y: 7))
        #expect(testMap.legalMoves == [.walkLeft, .walkRight])

        await testMap.doNextMove(.walkLeft)
        #expect(testMap.heroPosition! == (x: 9, y: 7))
        #expect(testMap.legalMoves == [.walkLeft, .walkRight, .walkDown])

        await testMap.doNextMove(.walkLeft)
        #expect(testMap.heroPosition! == (x: 8, y: 7))
        #expect(testMap.legalMoves == [.walkLeft, .walkUp, .walkRight])

        await testMap.doNextMove(.walkLeft)
        #expect(testMap.heroPosition! == (x: 7, y: 7))
        #expect(testMap.legalMoves == [.walkLeft, .walkRight])

        await testMap.doNextMove(.walkLeft)
        #expect(testMap.heroPosition! == (x: 6, y: 7))
        #expect(testMap.legalMoves == [.pushLeft, .walkRight])

        await testMap.doNextMove(.pushLeft)
        #expect(testMap.heroPosition! == (x: 5, y: 7))
        #expect(testMap.legalMoves == [.pushLeft, .walkUp, .walkRight, .walkDown])
    }

    @Test func isCompleted() async throws {
        let emptyMap = await Map.empty
        #expect(emptyMap.isCompleted == true)

        let testMap = await Map.mapFromXsb(string: testXsb)!
        #expect(testMap.isCompleted == false)
    }

    @Test func objectsOfType() async throws {
        let emptyMap = await Map.empty
        #expect(emptyMap.objectsOfType(.hero).isEmpty)
        #expect(emptyMap.objectsOfType(.box).isEmpty)

        let testMap = await Map.mapFromXsb(string: testXsb)!
        #expect(testMap.objectsOfType(.hero).count == 1)
        #expect(testMap.objectsOfType(.box).count == 6)
    }

    @Test func doNextMove() async throws {

        // four way walk
        var testMap = await Map.mapFromXsb(string: testXsb)!
        #expect(testMap.heroPosition! == (x: 11, y: 8))
        await testMap.doNextMove(.walkUp)
        #expect(testMap.heroPosition! == (x: 11, y: 7))
        await testMap.doNextMove(.walkLeft)
        #expect(testMap.heroPosition! == (x: 10, y: 7))
        await testMap.doNextMove(.walkRight)
        #expect(testMap.heroPosition! == (x: 11, y: 7))
        await testMap.doNextMove(.walkDown)
        #expect(testMap.heroPosition! == (x: 11, y: 8))
        
        // push left
        testMap = await Map.mapFromXsb(string: testXsb)!
        await testMap.removeObjectAt(x: 11, y: 8)
        await testMap.putObjectAt(x: 6, y: 7, type: .hero)
        await testMap.doNextMove(.pushLeft)
        await #expect(testMap.objectAt(x: 4, y: 7)?.type == .box)
        await #expect(testMap.objectAt(x: 5, y: 7)?.type == .hero)
        await #expect(testMap.isObjectAt(x: 6, y: 7) == false)

        // push up
        testMap = await Map.mapFromXsb(string: testXsb)!
        await testMap.removeObjectAt(x: 11, y: 8)
        await testMap.putObjectAt(x: 5, y: 8, type: .hero)
        await testMap.doNextMove(.pushUp)
        await #expect(testMap.objectAt(x: 5, y: 6)?.type == .box)
        await #expect(testMap.objectAt(x: 5, y: 7)?.type == .hero)
        await #expect(testMap.isObjectAt(x: 5, y: 8) == false)
        
        // push right
        testMap = await Map.mapFromXsb(string: testXsb)!
        await testMap.removeObjectAt(x: 11, y: 8)
        await testMap.putObjectAt(x: 4, y: 7, type: .hero)
        await testMap.doNextMove(.pushRight)
        await #expect(testMap.objectAt(x: 6, y: 7)?.type == .box)
        await #expect(testMap.objectAt(x: 5, y: 7)?.type == .hero)
        await #expect(testMap.isObjectAt(x: 4, y: 7) == false)

        // push down
        testMap = await Map.mapFromXsb(string: testXsb)!
        await testMap.removeObjectAt(x: 11, y: 8)
        await testMap.putObjectAt(x: 5, y: 6, type: .hero)
        await testMap.doNextMove(.pushDown)
        await #expect(testMap.objectAt(x: 5, y: 8)?.type == .box)
        await #expect(testMap.objectAt(x: 5, y: 7)?.type == .hero)
        await #expect(testMap.isObjectAt(x: 5, y: 6) == false)
    }

}

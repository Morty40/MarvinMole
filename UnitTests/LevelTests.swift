//
//  LevelTests.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation
import Testing
@testable import MarvinMole

struct LevelTests {

    /// All levels, in every collection
    static let resources = MapManager.MapCollection.allCases.flatMap { collection in
        (1 ... collection.count).map { String(format: collection.resourceName, $0) }
    }

    /// Every level loads, has a title, one hero, and as many boxes as goals
    @Test(arguments: resources) func levelLoads(resource: String) async throws {
        let map = try #require(await Map.mapFromBundle(resource: resource), "\(resource) missing")
        #expect(await map.title?.isEmpty == false, "\(resource) has no title")
        #expect(await map.count(of: .hero) == 1, "\(resource)")
        let boxes = await map.count(of: .box)
        let goals = await map.count(of: .floorGoal)
        #expect(boxes == goals, "\(resource): \(boxes) boxes, \(goals) goals")
    }

    /// Every level has a solution, and playing it move by move completes the level
    @Test(arguments: resources) func solutionSolvesLevel(resource: String) async throws {
        let map = try #require(await Map.mapFromBundle(resource: resource), "\(resource) missing")
        let solution = try #require(await map.solution, "\(resource) has no solution")
        let moves = Map.movesFrom(lurd: solution)
        #expect(moves.count == solution.count, "\(resource): solution has characters that are not moves")
        for (i, move) in moves.enumerated() {
            try #require(await map.legalMoves.contains(move), "\(resource): move \(i + 1) (\(move.rawValue)) is not legal")
            await map.makeMove(move)
        }
        #expect(await map.isCompleted, "\(resource): the solution does not complete the level")
    }
}

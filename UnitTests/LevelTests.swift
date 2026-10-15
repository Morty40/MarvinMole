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

    /// Every level of the Easy collection loads, has a title, one hero,
    /// and as many boxes as goals
    @Test func easyLevelsLoad() async throws {
        let collection = MapManager.MapCollection.easy
        for number in 1 ... collection.count {
            let resource = String(format: collection.resourceName, number)
            let map = try #require(await Map.mapFromBundle(resource: resource), "\(resource) missing")
            #expect(await map.title?.isEmpty == false, "\(resource) has no title")
            #expect(await map.count(of: .hero) == 1, "\(resource)")
            let boxes = await map.count(of: .box)
            let goals = await map.count(of: .floorGoal)
            #expect(boxes == goals, "\(resource): \(boxes) boxes, \(goals) goals")
        }
    }
}

//
//  ChessboardTransitionTests.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Testing
@testable import MarvinMole

struct ChessboardTransitionTests {

    @Test func spiralSteps() async throws {
        let steps = ChessboardTransitionFilter.spiralSteps(columns: 8, rows: 6)

        // expected steps, top row first (the function returns the bottom row first)
        let expected = [
            [ 0,  1,  2,  3,  4,  5,  6,  7],
            [11, 12, 13, 14, 15, 16, 17,  8],
            [10, 19, 20, 21, 22, 23, 18,  9],
            [ 9, 18, 23, 22, 21, 20, 19, 10],
            [ 8, 17, 16, 15, 14, 13, 12, 11],
            [ 7,  6,  5,  4,  3,  2,  1,  0],
        ]
        #expect(steps == expected.reversed().flatMap { $0 })
    }

    @Test func spiralStepsCoverEverySquare() async throws {
        // every square is filled, by at most two snakes per step, without gaps in the steps
        // (an odd number of squares leaves the last step to a single snake)
        for (columns, rows) in [(8, 6), (4, 4), (6, 2), (5, 3)] {
            let steps = ChessboardTransitionFilter.spiralSteps(columns: columns, rows: rows)
            #expect(steps.count == columns * rows)
            let counts = Dictionary(grouping: steps, by: { $0 }).mapValues(\.count)
            #expect(counts.values.allSatisfy { $0 <= 2 })
            #expect(Set(steps) == Set(0 ..< (columns * rows + 1) / 2))
        }
    }
}

//
//  MapManager.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation

final class MapManager {
    static var shared = MapManager()
    
    enum MapCollection: String, Codable, CaseIterable {
        case easy = "EASY"
        case medium = "MEDIUM"
        case classic = "CLASSIC"
        
        var title: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .classic: return "Classic"
            }
        }
        
        var count: Int {
            switch self {
            case .easy: return 3
            case .medium: return 3
            case .classic: return 50
            }
        }
        
        var resourceName: String {
            switch self {
            case .easy: return "Easy%02d"
            case .medium: return "Medium%02d"
            case .classic: return "Classic%02d"
            }
        }
    }
    
    struct MapSelection: Codable {
        var collection: MapCollection
        var number: Int
        
        var resourceName: String {
            String(format: collection.resourceName, number)
        }
    }
    
    var selectedMap: MapSelection = .init(collection: .easy, number: 1)
    
    struct MapSolution: Codable {
        var resourceName: String
        var moves: String
    }
    
    var solvedMaps: [MapSolution] = []
    
    func incrementMapNumber() {
        selectedMap.number += 1
        if selectedMap.number > selectedMap.collection.count {
            selectedMap.number = 1
        }
    }
    
    func register(solution: MapSolution) {
        
        // check if this map was solved previously
        if let index = solvedMaps.firstIndex(where: { $0.resourceName == solution.resourceName }) {
            
            // update solution if an improvement
            if solution.moves.count < solvedMaps[index].moves.count {
                solvedMaps[index] = solution
            }
            
            // TODO: if equal count, compare pushes
            
        } else {
            solvedMaps.append(solution)
        }
    }
    
    func mapSolutionFor(resourceName: String) -> MapSolution? {
        solvedMaps.first(where: { $0.resourceName == resourceName })
    }
    
    /// Total number of maps, counting all maps in all collections
    var totalNumberOfMaps: Int {
        MapCollection.allCases.map(\.count).reduce(0, +)
    }
    
    /// Total number of maps with solutions, matching all maps in all collections
    /// (in case maps are added or removed in an update, this should work)
    var totalNumberOfSolvedMaps: Int {
        var solved: Int = 0
        for collection in MapCollection.allCases {
            for i in 1 ... collection.count {
                if solvedMaps.contains(where: { $0.resourceName == String(format: collection.resourceName, i) }) {
                    solved += 1
                }
            }
        }
        
        return solved
    }
    
}

/// Load/save to json file in Documents directory
extension MapManager: Codable {
    
    static let fileURL = URL.documentsDirectory.appendingPathComponent("marvin.json")

    private enum CodingKeys: String, CodingKey {
        case selectedMap
        case solvedMaps
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedMap = try container.decode(MapSelection.self, forKey: .selectedMap)
        self.solvedMaps = try container.decode([MapSolution].self, forKey: .solvedMaps)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedMap, forKey: .selectedMap)
        try container.encode(solvedMaps, forKey: .solvedMaps)
    }
    
    /// Load state (selected map, solved maps)
    func load() {
        do {
            let data = try Data(contentsOf: Self.fileURL)
            Self.shared = try JSONDecoder().decode(MapManager.self, from: data)

        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Save state (selected map, solved maps)
    func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        
        do {
            let json = try encoder.encode(self)
            try json.write(to: Self.fileURL)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

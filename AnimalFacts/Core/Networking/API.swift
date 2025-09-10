//
//  CategoryDTO 2.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import ComposableArchitecture
import Foundation

public struct AnimalsAPI {
    public var fetchAnimals: @Sendable () async throws -> [CategoryDTO]
}

public extension AnimalsAPI {
    static func live(session: URLSession) -> Self {
        .init(fetchAnimals: {
            let url = URL(string: "https://raw.githubusercontent.com/AppSci/promova-test-task-iOS/main/animals.json")!
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, resp) = try await session.data(for: req)
            if let http = resp as? HTTPURLResponse,
               !(200..<300).contains(http.statusCode) {
                throw URLError(.badServerResponse)
            }
            
            return try JSONDecoder().decode([CategoryDTO].self, from: data)
        })
    }
    
    static func mock(_ items: [CategoryDTO] = []) -> Self {
        .init(fetchAnimals: { items })
    }
}

public extension DependencyValues {
    var animalsAPI: AnimalsAPI {
        get { self[AnimalsAPIKey.self] }
        set { self[AnimalsAPIKey.self] = newValue }
    }
}

// MARK: - DependencyKey

private enum AnimalsAPIKey: DependencyKey {
    static var liveValue: AnimalsAPI {
        @Dependency(\.networkSession) var net
        return .live(session: net.session)
    }
}

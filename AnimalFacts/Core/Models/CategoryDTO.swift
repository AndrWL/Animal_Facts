//
//  CategoryDTO.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import Foundation

public struct CategoryDTO: Decodable, Equatable {
    public let title: String
    public let description: String
    public let image: String?
    public let order: Int
    public let status: String
    public let content: [FactDTO]?
}

public struct FactDTO: Decodable, Equatable {
    public let fact: String
    public let image: String?
}

//
//  CacheBox.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import Foundation

public final class CacheBox<T>: NSObject {
    public let value: T
    public let timestamp: Date
    
    public init(_ value: T, timestamp: Date = Date()) {
        self.value = value
        self.timestamp = timestamp
    }
}

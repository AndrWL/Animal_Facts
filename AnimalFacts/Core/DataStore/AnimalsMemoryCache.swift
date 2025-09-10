//
//  AnimalsMemoryCache.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import Foundation

public actor AnimalsMemoryCache {
    private let cache = NSCache<NSString, CacheBox<[CategoryDTO]>>()
    private let key: NSString = "animals_v1"
    
    public init() {
        cache.countLimit = 1
        cache.totalCostLimit = 4 * 1024 * 1024
    }
    
    public func read() -> (items: [CategoryDTO], timestamp: Date)? {
        guard let box = cache.object(forKey: key) else { return nil }
        return (box.value, box.timestamp)
    }
    
    public func write(_ items: [CategoryDTO]) {
        cache.setObject(CacheBox(items), forKey: key)
    }
    
    public func clear() {
        cache.removeAllObjects()
    }
}

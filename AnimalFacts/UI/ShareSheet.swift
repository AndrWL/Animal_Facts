//
//  ShareSheet.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 12.09.2025.
//


import UIKit

struct ShareSheet {
    static func present(items: [Any]) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        root.present(activityVC, animated: true)
    }
}
//
//  AppTheme.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 11.09.2025.
//

import SwiftUI

public struct AppTheme: Equatable {
    public var background: Color
    public var cardBackground: Color
    public var textPrimary: Color
    public var accent: Color

    public static let main = AppTheme(
        background: Color(hex: "#BEC8FF"),
        cardBackground: .white,
        textPrimary: .black,
        accent: Color(hex: "#083AEB")
    )
}

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .main
}

public extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

public extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}

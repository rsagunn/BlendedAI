//
//  AIProvider.swift
//  BlendedAI
//

import Foundation

enum AIProvider: String, CaseIterable, Identifiable, Codable {
    case apple
    case gemini

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .apple: "Apple"
        case .gemini: "Gemini"
        }
    }
}

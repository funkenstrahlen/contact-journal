//
//  File.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 25.10.20.
//

import Foundation
import SwiftUI

@objc
public enum RiskLevel: Int64, CaseIterable {
    case low, high
}

public extension RiskLevel {
    var color: Color {
        switch self {
        case .high: return .red
        case .low: return .green
        }
    }
    
    var icon: Image {
        switch self {
        case .high: return Image(systemName: "exclamationmark.shield.fill")
        case .low: return Image(systemName: "checkmark.shield.fill")
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .high: return "erhöht"
        case .low: return "gering"
        }
    }
}

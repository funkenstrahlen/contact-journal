//
//  File.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 25.10.20.
//

import Foundation
import SwiftUI

public enum RiskLevel {
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

extension Item {
    public var riskLevel: RiskLevel {
        return .low
    }
}

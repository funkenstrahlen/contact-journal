//
//  LocationPoiPicker.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 28.10.20.
//

import SwiftUI
import MapKit

struct LocationPoiPicker: View {
    @State private var matchingItems = [MKMapItem]()
    @Binding var selectedLocationAddress: String
    @Binding var showsLocationPicker: Bool
    
    var body: some View {
        List {
            LocationSearchBar(matchingItems: $matchingItems, placeholder: "z.B. Starbucks Berlin")
            ForEach(matchingItems, id: \.self) { item in
                MapItemRow(item: item).onTapGesture {
                    selectedLocationAddress = item.description
                    showsLocationPicker = false
                }
            }
        }
    }
}

struct MapItemRow: View {
    let item: MKMapItem
    
    private var address: String {
        var string = ""
        if let street = item.placemark.postalAddress?.street, !street.isEmpty {
            string.append("\(street), ")
        }
        string.append("\(item.placemark.postalAddress?.city ?? "")")
        return string
    }
    
    private var iconName: String {
        switch item.pointOfInterestCategory {
        default: return "mappin.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch item.pointOfInterestCategory {
        default: return Color.red
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName).foregroundColor(iconColor).font(.title2)
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name ?? "").font(.headline)
                Text(address).font(.subheadline).foregroundColor(.secondary)
            }
        }
    }
}

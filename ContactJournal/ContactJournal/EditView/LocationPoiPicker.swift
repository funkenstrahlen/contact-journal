//
//  LocationPoiPicker.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 28.10.20.
//

import SwiftUI
import MapKit

struct MapItemRow: View {
    let item: MKMapItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.name ?? "")
            Text(item.placemark.postalAddress?.description ?? "")
        }
        
    }
}

struct LocationPoiPicker: View {
    @State private var matchingItems = [MKMapItem]()
    
    var body: some View {
        List {
            LocationSearchBar(matchingItems: $matchingItems, placeholder: "z.B. Starbucks Berlin")
            ForEach(matchingItems, id: \.self) { item in
                MapItemRow(item: item)
            }
        }
    }
}

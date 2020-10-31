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
        NavigationView {
            List {
                LocationSearchBar(matchingItems: $matchingItems, placeholder: "z.B. Starbucks Berlin")
                ForEach(matchingItems, id: \.self) { item in
                    MapItemRow(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedLocationAddress = item.fullDescription
                            showsLocationPicker = false
                        }
                }
            }
            .listStyle(DefaultListStyle())
            .navigationBarTitle(Text("Adresse suchen"), displayMode: .inline)
            .toolbar(content: {
                ToolbarItem {
                    Button(action: {
                        endEditing()
                        showsLocationPicker = true // workaround because keyboard breaks state
                        showsLocationPicker = false
                    }, label: {
                        Text("Abbrechen")
                    })
                }
            })
        }
    }
}

fileprivate extension MKMapItem {
    var fullDescription: String {
        var string = ""
        if let name = name {
            string.append("\(name)\n")
        }
        if let street = placemark.postalAddress?.street, !street.isEmpty {
            string.append("\(street)\n")
        }
        if let postalCode = placemark.postalAddress?.postalCode, !postalCode.isEmpty {
            string.append("\(postalCode) ")
        }
        if let city = placemark.postalAddress?.city, !city.isEmpty {
            string.append("\(city)\n")
        }
        if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            string.append("\(phoneNumber)\n")
        }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
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
            Spacer()
        }
    }
}

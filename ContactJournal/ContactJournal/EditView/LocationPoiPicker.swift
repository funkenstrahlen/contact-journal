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
            SearchBar(matchingItems: $matchingItems, placeholder: "z.B. Starbucks Berlin")
            ForEach(matchingItems, id: \.self) { item in
                MapItemRow(item: item)
            }
        }
    }
}

struct SearchBar: UIViewRepresentable {

    @Binding var matchingItems: [MKMapItem]
    
    let placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {
        
        private var search: MKLocalSearch?
        private var searchText = ""
        
        @Binding var matchingItems: [MKMapItem]

        init(matchingItems: Binding<[MKMapItem]>) {
            _matchingItems = matchingItems
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
            if searchText.isEmpty {
                matchingItems = []
            }
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            updateSearchResults()
            searchBar.resignFirstResponder()
        }
        
        func updateSearchResults() {
            search?.cancel()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.resultTypes = [.address, .pointOfInterest]
            request.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [.atm, .fireStation, .parking])
            search = MKLocalSearch(request: request)
            
            search?.start { response, _ in
                DispatchQueue.main.async {
                    self.matchingItems = response?.mapItems ?? []
                }
            }
        }
    }
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(matchingItems: $matchingItems)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = placeholder
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
    }
    
}

struct LocationPoiPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationPoiPicker()
        }
    }
}

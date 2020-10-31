//
//  LocationPoiPicker.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 28.10.20.
//

import SwiftUI
import MapKit

struct LocationPoiPicker: View {
    @State private var searchString = ""
    @State private var matchingItems = [MKMapItem]()
    
    var body: some View {
        List {
            SearchBar(text: $searchString, matchingItems: $matchingItems, placeholder: "z.B. Starbucks Berlin")
            ForEach(matchingItems, id: \.self) { item in
                Text(item.description)
            }
        }
    }
}

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    @Binding var matchingItems: [MKMapItem]
    
    let placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {
        
        private var search: MKLocalSearch?

        @Binding var searchText: String
        @Binding var matchingItems: [MKMapItem]

        init(text: Binding<String>, matchingItems: Binding<[MKMapItem]>) {
            _searchText = text
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
            print(searchText)
            
    //        var pointOfInterestFilter: MKPointOfInterestFilter?
    //        A filter that lists point of interest categories to include or exclude in search results.
    //        var resultTypes: MKLocalSearch.ResultType
    //        The types of items to include in the search results.
            search?.cancel()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            search = MKLocalSearch(request: request)
            
            search?.start { response, _ in
                DispatchQueue.main.async {
                    self.matchingItems = response?.mapItems ?? []
                }
            }
        }
    }
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, matchingItems: $matchingItems)
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
        uiView.text = text
    }
    
}

struct LocationPoiPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationPoiPicker()
        }
    }
}

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
    @State private var search: MKLocalSearch?
    
    var body: some View {
        List {
            SearchBar(text: $searchString, placeholder: "z.B. Starbucks Berlin")
            ForEach(matchingItems, id: \.self) { item in
                Text(item.description)
            }
        }.onReceive(searchString.publisher, perform: { searchString in
            updateSearchResults(searchString: self.searchString)
        })
    }
    
    func updateSearchResults(searchString: String) {
        print(searchString)
        
//        var pointOfInterestFilter: MKPointOfInterestFilter?
//        A filter that lists point of interest categories to include or exclude in search results.
//        var resultTypes: MKLocalSearch.ResultType
//        The types of items to include in the search results.
        search?.cancel()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchString
        search = MKLocalSearch(request: request)
        
        search?.start { response, _ in
            DispatchQueue.main.async {
                self.matchingItems = response?.mapItems ?? []
            }
        }
    }
}

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    let placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
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

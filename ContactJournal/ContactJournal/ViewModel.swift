//
//  ViewModel.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 31.10.20.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    @Published var showsCreateItemButton = true
    
    @Published var showsSettings = false {
        willSet {
            showsCreateItemButton = !newValue
        }
    }
    @Published var showsDonation = false {
        willSet {
            showsCreateItemButton = !newValue
        }
    }
    @Published var showsShareSheet = false {
        willSet {
            showsCreateItemButton = !newValue
        }
    }
    @Published var selectedItem: Item?
    @Published var linkIsActive = false {
        willSet {
            showsCreateItemButton = !newValue
        }
    }
}

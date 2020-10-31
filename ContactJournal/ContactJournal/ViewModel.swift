//
//  ViewModel.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 31.10.20.
//

import Foundation
import Combine
import SwiftUI

class ViewModel: ObservableObject {
    @Published var showsCreateItemButton = true
    
    @Published var showsSettings = false {
        willSet {
            withAnimation {
                showsCreateItemButton = !newValue
            }
        }
    }
    @Published var showsDonation = false {
        willSet {
            withAnimation {
                showsCreateItemButton = !newValue
            }
        }
    }
    @Published var showsShareSheet = false {
        willSet {
            withAnimation {
                showsCreateItemButton = !newValue
            }
        }
    }
    @Published var selectedItem: Item?
    @Published var linkIsActive = false {
        willSet {
            withAnimation {
                showsCreateItemButton = !newValue
            }
        }
    }
}

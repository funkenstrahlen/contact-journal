//
//  CreateItemButton.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 25.10.20.
//

import Foundation
import SwiftUI

struct CreateItemButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(CreateItemButtonStyle())
                .accessibility(label: Text("Neuer Eintrag"))
                .scaleEffect(viewModel.showsCreateItemButton ? 1.0 : 0)
                .accessibility(hidden: !viewModel.showsCreateItemButton)
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            viewModel.selectedItem = newItem
            viewModel.linkIsActive = true
            PersistenceController.saveContext()
        }
    }
}

struct CreateItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(Color(UIColor.systemBackground))
            .font(.system(size: 55))
            .clipShape(Circle())
            .foregroundColor(.blue)
            .shadow(radius: 3)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .padding()
            .padding()
    }
}

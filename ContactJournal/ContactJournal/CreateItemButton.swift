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
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                }.background(Color(UIColor.systemBackground))
                .font(.system(size: 50))
                .clipShape(Circle())
                .foregroundColor(.blue)
                .padding(.horizontal)
                .padding(.horizontal)
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            PersistenceController.saveContext()
        }
    }
}

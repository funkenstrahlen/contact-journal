//
//  ContentView.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    private var hasDeprecatedItems: Bool {
        items.contains(where: { $0.isDeprecated })
    }

    var body: some View {
        NavigationView {
            List {
                if items.count == 0 {
                    Button(action: addItem) {
                        Label("Neuer Eintrag", systemImage: "plus.circle.fill").foregroundColor(.blue)
                    }
                }

                ForEach(items) { item in
                    ItemRow(item: item)
                }
                .onDelete(perform: deleteSelectedItems)
                
                if hasDeprecatedItems {
                    Button(action: deleteDeprecatedItems) {
                        Label("Alle Einträge älter als 14 Tage löschen", systemImage: "trash").foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Kontakt Tagebuch")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addItem) {
                        Label("Neuer Eintrag", systemImage: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if items.count > 0 {
                        EditButton()
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            saveContext()
        }
    }

    private func deleteSelectedItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func deleteDeprecatedItems() {
        withAnimation {
            items.filter({ $0.isDeprecated }).forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

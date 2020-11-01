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
    
    @State private var showsSettings = false
    @State private var showsShareSheet = false
    @State private var showsDonation = false
    @State private var showsEditView = false
    @State private var showsEditViewRow = false
    @State private var newItem: Item?
    
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
                    NavigationLink(destination: EditView(item: item, deleteItem: deleteItem(item:)), isActive: $showsEditViewRow){
                        ItemRow(item: item)
                    }
                }
                .onDelete(perform: deleteSelectedItems)
                
                if hasDeprecatedItems {
                    Spacer()
                    Button(action: deleteDeprecatedItems) {
                        Label("Alle Einträge älter als 3 Wochen löschen", systemImage: "trash").foregroundColor(.red)
                    }
                    Text("")
                }
            }
            .background(
                VStack {
                    if let item = newItem {
                        NavigationLink(destination: EditView(item: item, deleteItem: deleteItem(item:)), isActive: $showsEditView) {
                            EmptyView()
                        }
                    }
                    NavigationLink(destination: Settings(), isActive: $showsSettings) {
                        EmptyView()
                    }
                    NavigationLink(destination: DonationView(), isActive: $showsDonation) {
                        EmptyView()
                    }
                    EmptyView().sheet(isPresented: $showsShareSheet) {
                        ShareExportActivityViewController(activityItems: [Exporter.exportFileURL]) { (_, _, _, _) in
                            showsShareSheet = false
                        }
                    }
                })
            .navigationBarTitle("Kontakt-Tagebuch")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showsSettings = true
                    }, label: {
                        Label("Einstellungen", systemImage: "gearshape")
                    })
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showsDonation = true
                    }, label: {
                        Label("Danke sagen", systemImage: "heart")
                    })
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: exportCSV) {
                        Label("Exportieren", systemImage: "square.and.arrow.up")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addItem) {
                        Label("Neuer Eintrag", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
    }
    
    private func deleteItem(item: Item) {
        withAnimation {
            showsEditView = false
            showsEditViewRow = false
            DispatchQueue.main.async {
                viewContext.delete(item)
                PersistenceController.saveContext()
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            self.newItem = newItem
            showsEditView = true
            PersistenceController.saveContext()
        }
    }
    
    private func exportCSV() {
        Exporter.generateCSVExport()
        showsShareSheet = true
    }
    
    private func deleteSelectedItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            PersistenceController.saveContext()
        }
    }
    
    private func deleteDeprecatedItems() {
        withAnimation {
            PersistenceController.deleteDeprecatedItems()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

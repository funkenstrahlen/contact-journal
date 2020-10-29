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
    
    @State private var selectedItem: Item?
    @State private var linkIsActive = false
    
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
                    Button(action: {
                        self.selectedItem = item
                        self.linkIsActive = true
                    }) {
                        NavigationLink(destination: EmptyView()){
                            ItemRow(item: item)
                        }
                    }
                }
                .onDelete(perform: deleteSelectedItems)
                
                if hasDeprecatedItems {
                    Spacer()
                    Button(action: deleteDeprecatedItems) {
                        Label("Alle Einträge älter als 14 Tage löschen", systemImage: "trash").foregroundColor(.red)
                    }
                    Text("")
                }
            }
            .background(
                VStack {
                    NavigationLink(
                        destination: linkDestination(selectedItem: selectedItem),
                        isActive: $linkIsActive) {
                        EmptyView()
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showsDonation = true
                    }, label: {
                        Label("Danke", systemImage: "heart")
                    })
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showsSettings = true
                    }, label: {
                        Label("Einstellungen", systemImage: "gearshape")
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
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if items.count > 0 {
                        EditButton()
                    }
                }
            }
        }
    }
    
    struct linkDestination: View {
        let selectedItem: Item?
        var body: some View {
            return Group {
                if selectedItem != nil {
                    EditView(item: selectedItem!)
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            selectedItem = newItem
            linkIsActive = true
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

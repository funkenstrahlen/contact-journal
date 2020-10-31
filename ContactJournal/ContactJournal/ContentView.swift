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
    @EnvironmentObject private var viewModel: ViewModel
    
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
                ForEach(items) { item in
                    Button(action: {
                        viewModel.selectedItem = item
                        viewModel.linkIsActive = true
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
                        Label("Alle Einträge älter als 3 Wochen löschen", systemImage: "trash").foregroundColor(.red)
                    }
                    Text("")
                }
            }
            .background(
                VStack {
                    NavigationLink(
                        destination: linkDestination(selectedItem: viewModel.selectedItem),
                        isActive: $viewModel.linkIsActive) {
                        EmptyView()
                    }
                    NavigationLink(destination: Settings(), isActive: $viewModel.showsSettings) {
                        EmptyView()
                    }
                    NavigationLink(destination: DonationView(), isActive: $viewModel.showsDonation) {
                        EmptyView()
                    }
                    EmptyView().sheet(isPresented: $viewModel.showsShareSheet) {
                        ShareExportActivityViewController(activityItems: [Exporter.exportFileURL]) { (_, _, _, _) in
                            viewModel.showsShareSheet = false
                        }
                    }
                })
            .navigationBarTitle("Kontakt-Tagebuch")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: exportCSV) {
                        Label("Exportieren", systemImage: "square.and.arrow.up")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showsDonation = true
                    }, label: {
                        Label("Danke sagen", systemImage: "heart")
                    })
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showsSettings = true
                    }, label: {
                        Label("Einstellungen", systemImage: "gearshape")
                    })
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
    
    private func exportCSV() {
        Exporter.generateCSVExport()
        viewModel.showsShareSheet = true
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

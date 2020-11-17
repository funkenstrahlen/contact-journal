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
    @State private var showsEditView = false
    @State private var newItem: Item?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d. MMMM"
        return formatter
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    private var groupedItems: [[Item]] {
        Dictionary(grouping: items){ (element : Item)  in
            dateFormatter.string(from: element.timestamp!)
        }.values.sorted() { $0[0].timestamp! > $1[0].timestamp! }
    }

    
    private var hasDeprecatedItems: Bool {
        items.contains(where: { $0.isDeprecated })
    }
    
    private func realtimeRelativeTimeFor(timestamp: Date) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        if Calendar.current.isDateInToday(timestamp) { return "heute" }
        if Calendar.current.isDateInYesterday(timestamp) { return "gestern" }
        let diffInDays = Calendar.current.dateComponents([.day], from: startOfDay, to: Calendar.current.startOfDay(for: timestamp)).day!
        if timestamp > Date() {
            return "in \(abs(diffInDays)) Tagen"
        } else {
            return "vor \(abs(diffInDays)) Tagen"
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if items.count == 0 {
                    Button(action: addItem) {
                        Label("Neuer Eintrag", systemImage: "plus.circle.fill").foregroundColor(.blue)
                    }
                }
                
                ForEach(groupedItems, id: \.self) { (section: [Item]) in
                    Section(header:
                            HStack {
                                Text(self.dateFormatter.string(from: section[0].timestamp!))
                                Spacer()
                                Text(self.realtimeRelativeTimeFor(timestamp: section[0].timestamp!))
                            }
                    ) {
                        ForEach(section, id: \.self) { item in
                            NavigationLink(destination: EditView(item: item)){
                                ItemRow(item: item)
                            }
                        }.onDelete { rows in
                            deleteSelectedItems(section: section, rows: rows)
                        }
                    }.textCase(nil)
                }
                
                
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
                        NavigationLink(destination: EditView(item: item), isActive: $showsEditView) {
                            EmptyView()
                        }
                    }
                    NavigationLink(destination: Settings(), isActive: $showsSettings) {
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
    
    private func deleteSelectedItems(section: [Item], rows: IndexSet) {
        withAnimation {
            rows.map { section[$0] }.forEach(viewContext.delete)
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

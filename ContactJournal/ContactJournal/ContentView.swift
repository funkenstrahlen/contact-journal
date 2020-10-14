//
//  ContentView.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI
import CoreData

struct EditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item
    
    var body: some View {
        Form {
            if(!item.isFault) {
                DatePicker("Datum", selection: $item.timestamp, in: ...Date())
                Section(header: Text("Kontakte")) {
                    TextEditor(text: $item.content)
                }
            }
        }.navigationBarTitle(Text(""), displayMode: .inline)
        .onDisappear(perform: {
            try! viewContext.save()
        })
    }
}



struct ItemRow: View {
    var item: Item
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd. MMM, HH:mm"
        return formatter
    }()

    private var relativeDateFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        return formatter
    }
    
    let timer = Timer.publish(
        every: 1, // second
        on: .main,
        in: .common
    ).autoconnect()
    
    @State var relativeTimeString = ""
    
    var body: some View {
        NavigationLink(destination: EditView(item: item)) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .lastTextBaseline) {
                    Text("\(item.timestamp, formatter: dateFormatter)").font(.subheadline)
                    Spacer()
                    Text(relativeTimeString).font(.caption).foregroundColor(.secondary)
                    .onReceive(timer) { (_) in
                        guard !item.isFault else { return }
                        self.relativeTimeString = relativeDateFormatter.localizedString(for: item.timestamp, relativeTo: Date())
                    }
                }
                if(item.content == "") {
                    Text("Keine Kontakte").foregroundColor(.secondary)
                } else {
                    Text(item.content).lineLimit(4)
                }
            }.padding([.vertical])
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                Button(action: addItem) {
                    Label("Neuer Eintrag", systemImage: "plus.circle.fill").foregroundColor(.blue)
                }
                ForEach(items) { item in
                    ItemRow(item: item)
                }
                .onDelete(perform: deleteItems)
                Button(action: deleteDeprecatedItems) {
                    Label("Alle Einträge älter als 14 Tage löschen", systemImage: "trash").foregroundColor(.red)
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
                    EditButton()
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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
    
    private func deleteDeprecatedItems() {
        withAnimation {
            let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
            items.filter({ $0.timestamp < twoWeeksAgo }).forEach(viewContext.delete)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

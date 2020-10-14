//
//  EditView.swift
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
            // check if item is valid because it might be deleted and this causes a crash here
            if(!item.isFault) {
                DatePicker("Datum", selection: $item.timestamp, in: ...Date())
                Section(header: Text("Kontakte"), footer: Text("Hier kannst du dokumentieren mit wem du Kontakt hattest. Kam es zu einer Situation, in der du keinen Abstand halten konntest oder viele Menschen zusammenkamen?")) {
                    TextEditor(text: $item.content)
                }
            }
        }.navigationBarTitle(Text(""), displayMode: .inline)
        .onDisappear(perform: {
            try! viewContext.save()
        })
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(item: Item(context: PersistenceController.preview.container.viewContext)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

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

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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        Form {
            // check if item is valid because it might be deleted and this causes a crash here
            if(!item.isFault) {
                DatePicker("Datum", selection: $item.timestamp, in: ...Date())
                Section(header: Text("Kontakte")) {
                    TextEditor(text: $item.content)
                }
            }
        }
        .navigationBarTitle(Text("\(item.timestamp, formatter: dateFormatter)"), displayMode: .inline)
        .onDisappear(perform: {
            try! viewContext.save()
        })
        .toolbar(content: {
            Button("Fertig") {
                UIApplication.shared.endEditing()
                try! viewContext.save()
            }
        })
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(item: Item(context: PersistenceController.preview.container.viewContext)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

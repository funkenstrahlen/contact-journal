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
    
    private var navigationBarTitle: String {
        guard !item.isFault else { return "" }
        return dateFormatter.string(from: item.timestamp)
    }
    
    var body: some View {
        Form {
            // check if item is valid because it might be deleted and this causes a crash here
            if !item.isFault {
                DatePicker("Zeitpunkt", selection: $item.timestamp, in: ...Date())
                Section(header: Text("Beschreibung"), footer: Text("z.B. Kaffee mit Pia")) {
                    MultilineTextView(text: $item.content)
                }
                Toggle("Maske getragen", isOn: $item.didWearMask)
                Toggle("Abstand gehalten", isOn: $item.couldKeepDistance)
                HStack {
                    Text("Ort")
                    Spacer()
                    Picker("Ort", selection: $item.isOutside) {
                        Text("Drinnen").tag(false)
                        Text("Draußen").tag(true)
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Stepper(value: $item.personCount, in: 1...200) {
                    Text("\(item.personCount) \(item.personCount > 1 ? "Personen" : "Person")")
                }
                Stepper(value: $item.durationHours, in: 0.25...24, step: 0.25) {
                    Text("\(item.durationHours, specifier: "%g") \(item.durationHours != 1 ? "Stunden" : "Stunde")")
                }
                Section(header: Text("Kontaktdaten"), footer: Text("z.B. Telefonnummer, Adresse, E-Mail")) {
                    MultilineTextView(text: $item.contactDetails)
                }
            }
        }
        .navigationBarTitle(Text(navigationBarTitle), displayMode: .inline)
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

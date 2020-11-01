//
//  EditView.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI
import CoreData
import Contacts

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
    
    @State private var showsContactPicker = false
    
    var body: some View {
        // check if item is valid because it might be deleted and this causes a crash here
        if !item.isFault {
            Form {
                Section(header: Text("Beschreibung")) {
                    MultilineTextField(placeholder: "z.B. Kaffee mit Pia", text: $item.content)
                }
                
                Section {
                    DatePicker("", selection: $item.timestamp).datePickerStyle(WheelDatePickerStyle())
                    Stepper(value: $item.durationHours, in: 0.25...24, step: 0.25) {
                        Text("Dauer: \(item.durationHours, specifier: "%g") \(item.durationHours != 1 ? "Stunden" : "Stunde")")
                    }
                }

                Toggle("Mund-Nasen-Bedeckung getragen", isOn: $item.didWearMask)
                Toggle("Abstand gehalten", isOn: $item.couldKeepDistance)
                HStack {
                    Text("Ort")
                    Spacer()
                    Picker("Ort", selection: $item.isOutside) {
                        Text("🏠 Drinnen").tag(false)
                        Text("🌤 Draußen").tag(true)
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Stepper(value: $item.personCount, in: 1...200) {
                    Text("\(item.personCount) \(item.personCount > 1 ? "Personen" : "Person")")
                }
                Section(header: Text("Kontaktdaten")) {
                    MultilineTextField(placeholder: "z.B. Telefonnummer, Adresse, E-Mail", text: $item.contactDetails)
                    Button(action: { showsContactPicker = true }, label: {
                        Label("Aus Adressbuch importieren", systemImage: "person.crop.circle.badge.plus")
                    })
                }
            }
            .navigationBarTitle(Text(navigationBarTitle), displayMode: .inline)
            .onDisappear(perform: {
                try! viewContext.save()
            })
            .sheet(isPresented: $showsContactPicker, content: {
                ContactPicker(showPicker: $showsContactPicker, onSelectContact: didSelectContact(contact:))
            })
        }
    }
    
    private func didSelectContact(contact: CNContact) {
        append(contact: contact)
    }
    
    private func append(contact: CNContact) {
        var contactString = "\n\n"
        contactString.append("\(contact.givenName) \(contact.familyName)")
        
        if !contact.organizationName.isEmpty {
            contactString.append("\n\(contact.organizationName)")
        }
        
        if let postalAddress = contact.postalAddresses.first {
            contactString.append("\n\(postalAddress.value.street)\n\(postalAddress.value.postalCode) \(postalAddress.value.city)")
        }
        if let phoneNumber = contact.phoneNumbers.first {
            contactString.append("\n\(phoneNumber.value.stringValue)")
        }
        if let emailAddress = contact.emailAddresses.first {
            contactString.append("\n\(emailAddress.value)")
        }
        
        item.contactDetails.append(contactString)
        item.contactDetails = item.contactDetails.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditView(item: Item(context: PersistenceController.preview.container.viewContext)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

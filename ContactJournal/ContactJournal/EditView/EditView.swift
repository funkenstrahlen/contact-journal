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
        guard let timestamp = item.timestamp else { return "" }
        return dateFormatter.string(from: timestamp)
    }
    
    @State private var showsContactPicker = false
    @State private var showsLocationPicker = false
    
    var body: some View {
        // check if item is valid because it might be deleted and this causes a crash here
        if !item.isFault {
            Form {
                Section(header: Text("Beschreibung")) {
                    MultilineTextField(placeholder: "z.B. Kaffee mit Pia", text: $item.content)
                }
                
                Section {
                    DatePicker("Zeitpunkt",
                               selection: Binding<Date>(get: {item.timestamp ?? Date()}, set: {item.timestamp = $0}),
                               displayedComponents: item.isAllDay ? .date : [.date, .hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    if !item.isAllDay {
                        Stepper(value: $item.durationHours, in: 0.25...24, step: 0.25) {
                            Text("Dauer: \(item.durationHours, specifier: "%g") \(item.durationHours != 1 ? "Stunden" : "Stunde")")
                        }
                        .accessibility(label: Text("Dauer"))
                        .accessibility(value: Text("\(item.durationHours, specifier: "%g")"))
                        .accessibility(hint: Text("in Stunden"))
                    }
                    Toggle("Ganzer Tag", isOn: $item.isAllDay.animation())
                }

                Section {
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
                    .accessibility(label: Text("Personenzahl"))
                    .accessibility(value: Text("\(item.personCount)"))
                    HStack {
                        Text("Empfundenes Ansteckungsrisiko")
                        Spacer()
                        Picker("", selection: $item.riskLevel) {
                            ForEach(RiskLevel.allCases, id: \.self) { riskLevel in
                                HStack {
                                    riskLevel.icon
                                    Text(riskLevel.localizedDescription)
                                }.accessibility(label: Text(riskLevel.localizedDescription))
                                .foregroundColor(riskLevel.color)
                                .tag(riskLevel)
                            }
                        }
                    }
                }

                
                Section(header: Text("Kontaktdaten")) {
                    MultilineTextField(placeholder: "z.B. Telefonnummer, Adresse, E-Mail", text: $item.contactDetails)
                        .sheet(isPresented: $showsContactPicker, content: {
                            ContactPicker(showPicker: $showsContactPicker, onSelectContact: didSelectContact(contact:))
                        })
                    Button(action: { showsContactPicker = true }, label: {
                        Label("Aus Adressbuch importieren", systemImage: "person.crop.circle.badge.plus")
                    })

                }
                
                Section(header: Text("Ort")) {
                    MultilineTextField(placeholder: "z.B. Adresse", text: $item.location)
                        .sheet(isPresented: $showsLocationPicker, content: {
                            LocationPoiPicker(onSelectLocation: { newLocation in
                                item.location = newLocation
                            })
                        })
                    Button(action: {
                        showsLocationPicker = true
                    }, label: {
                        Label("Adresse suchen", systemImage: "map")
                    })

                }
            }
            .navigationBarTitle(Text(navigationBarTitle), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        PersistenceController.duplicate(item: item)
                    }) {
                        Label("Duplizieren", systemImage: "plus.square.on.square")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewContext.delete(item)
                        PersistenceController.saveContext()
                    }) {
                        Label("Löschen", systemImage: "trash")
                    }
                }
            }
            .onDisappear(perform: {
                try! viewContext.save()
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

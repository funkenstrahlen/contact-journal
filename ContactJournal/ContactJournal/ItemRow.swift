//
//  ItemRow.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI
import CoreData

struct ItemRow: View {
    var item: Item
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d. MMM HH:mm"
        return formatter
    }()

    private var relativeDateFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        return formatter
    }
    
    private let timer = Timer.publish(
        every: 1, // second
        on: .main,
        in: .common
    ).autoconnect()
    
    @State var realtimeRelativeTimeString: String?
    
    private var realtimeRelativeTime: String {
        relativeDateFormatter.localizedString(for: item.timestamp, relativeTo: Date())
    }
    
    var body: some View {
        NavigationLink(destination: EditView(item: item)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text("\(item.timestamp, formatter: dateFormatter)")
                    Spacer()
                    Text(realtimeRelativeTimeString ?? realtimeRelativeTime).foregroundColor(.secondary)
                }.font(.subheadline)
                if(item.content == "") {
                    Text("Neuer Eintrag").foregroundColor(.secondary).italic()
                } else {
                    Text(item.content).lineLimit(4)
                }
            }
            .padding([.vertical], 8)
            .onReceive(timer) { (_) in
                guard !item.isFault else { return }
                self.realtimeRelativeTimeString = realtimeRelativeTime
            }
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var item: Item {
        let item = Item(context: PersistenceController.preview.container.viewContext)
        item.content = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
        return item
    }
    
    static var newItem: Item {
        let item = Item(context: PersistenceController.preview.container.viewContext)
        return item
    }
    
    static var previews: some View {
        NavigationView {
            List {
                ItemRow(item: item)
                ItemRow(item: newItem)
            }
        }
    }
}

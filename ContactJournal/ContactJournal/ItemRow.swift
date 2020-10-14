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

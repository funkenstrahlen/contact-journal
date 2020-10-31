//
//  DonationView.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 25.10.20.
//

import SwiftUI
import StoreKit

struct DonationView: View {
    @StateObject private var productProvider = SKProductProvider()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Ich habe diese App entwickelt, weil ich ein Kontakt-Tagebuch für ein wichtiges Werkzeug in diesen Zeiten halte. Um es möglichst vielen Menschen leicht zu machen einen Beitrag zu leisten, ist die App kostenlos.")
                Text("Wenn dir die App gefällt und du mir eine Freude machen willst, dann kannst du mir hier ein kleines Dankeschön in den Hut werfen.")
                VStack {
                    ForEach(productProvider.products, id: \.self) { product in
                        PurchaseProductButton(product: product)
                    }
                }
                Spacer()
                Link("Impressum & Datenschutzerklärung", destination: URL(string: "https://stefantrauth.de/contact-journal-privacy-policy.html")!).padding(.vertical).font(.caption)
            }.padding()
        }.navigationBarTitle("Danke sagen")
    }
}

struct PurchaseProductButton: View {
    let product: SKProduct
    
    var body: some View {
        Button(action: purchase, label: {
            HStack {
                Image(systemName: "heart")
                VStack(alignment: .leading, spacing: 5) {
                    Text(product.localizedTitle).font(.headline)
                    Text(product.localizedDescription).font(.subheadline)
                }.fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text(product.localizedPrice).font(.title)
            }
            .padding()
        })
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
    
    private func purchase() {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}

//
//  MultilineTextView.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 17.10.20.
//

import Foundation
import SwiftUI

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.delegate = context.coordinator
        view.isScrollEnabled = false
        view.isEditable = true
        view.isUserInteractionEnabled = true
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: MultilineTextView

        init(_ uiTextView: MultilineTextView) {
            self.parent = uiTextView
        }

        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}

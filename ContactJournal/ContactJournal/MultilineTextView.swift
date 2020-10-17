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
    
    let view = UITextView()

    func makeUIView(context: Context) -> UITextView {
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.delegate = context.coordinator
        view.isScrollEnabled = false
        view.isEditable = true
        view.isUserInteractionEnabled = true
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.done))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        view.inputAccessoryView = keyboardToolbar
        
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
        
        @objc func done() {
            self.parent.view.endEditing(true)
        }
    }
}

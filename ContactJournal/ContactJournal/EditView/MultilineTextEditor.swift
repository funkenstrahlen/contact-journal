//
//  UITextViewWrapper.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 20.10.20.
//

import Foundation
import SwiftUI
import Combine

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct MultilineTextField: View {
    
    struct _State {
        var height: CGFloat?
    }
    
    @State var state = _State()

    let placeholder: String
    @Binding var text: String
    
    let placeholderColor: UIColor = UIColor(.secondary)
    let font: UIFont = UIFont.preferredFont(forTextStyle: .body)
    let textColor: UIColor = UIColor(.primary)
    
    var body: some View {
        GeometryReader { (geo: GeometryProxy) in
            self.content(with: geo)
        }
        .frame(height: state.height)
    }
    
    func content(with geo: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.init(placeholderColor))
                    .font(.init(font))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibility(hidden: true)
            }
            textView(with: geo)
        }
    }
    
    func textView(with geo: GeometryProxy) -> some View {
        TextView(
            make: { coordinator in
                let textView = UITextView()
                textView.backgroundColor = UIColor.clear
                textView.delegate = coordinator
                textView.isScrollEnabled = false
                textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                textView.textContainerInset = .zero
                textView.textContainer.lineFragmentPadding = 0
                textView.textColor = self.textColor
                textView.font = self.font
                
                let keyboardToolbar = UIToolbar()
                keyboardToolbar.sizeToFit()
                let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: textView, action: #selector(textView.endEditing(_:)))
                keyboardToolbar.items = [flexBarButton, doneBarButton]
                textView.inputAccessoryView = keyboardToolbar
                
                coordinator.text = self.$text
                coordinator.height = self.$state.height
                
                return textView
            },
            update: { uiView, coordinator  in
                if self.$text.wrappedValue != uiView.text {
                    uiView.text = self.$text.wrappedValue
                }
                coordinator.width = geo.size.width
                coordinator.adjustHeight(view: uiView)
        })
        .frame(height: state.height)
    }
    
}

struct TextView: UIViewRepresentable {
    
    typealias UIViewType = UITextView
    
    let make: (Coordinator) -> UIViewType
    let update: (UIViewType, Coordinator) -> Void
    
    func makeCoordinator() -> TextView.Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<TextView>) -> UIViewType {
        return make(context.coordinator)
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<TextView>) {
        update(uiView, context.coordinator)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {

        var text: Binding<String> = .constant("")
        var width: CGFloat = 0
        var height: Binding<CGFloat?> = .constant(nil)
        
        func textViewDidChange(_ textView: UITextView) {
            if text.wrappedValue != textView.text {
                text.wrappedValue = textView.text
            }
            adjustHeight(view: textView)
        }
        
        func adjustHeight(view: UITextView) {
            let bounds = CGSize(width: width, height: .infinity)
            let height = view.sizeThatFits(bounds).height
            OperationQueue.main.addOperation { [weak self] in
                self?.height.wrappedValue = height
            }
        }
        
    }
}

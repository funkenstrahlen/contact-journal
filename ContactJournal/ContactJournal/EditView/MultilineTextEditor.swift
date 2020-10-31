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
        var cursor: Binding<CGFloat?> = .constant(nil)
        
        func textViewDidChange(_ textView: UITextView) {
            if text.wrappedValue != textView.text {
                text.wrappedValue = textView.text
            }
            adjustHeight(view: textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            OperationQueue.main.addOperation { [weak self] in
                self?.cursor.wrappedValue = self?.absoleteCursor(view: textView)
            }
        }
        
        func adjustHeight(view: UITextView) {
            let bounds = CGSize(width: width, height: .infinity)
            let height = view.sizeThatFits(bounds).height
            OperationQueue.main.addOperation { [weak self] in
                self?.height.wrappedValue = height
            }
        }
        
        func absoleteCursor(view: UITextView) -> CGFloat? {
            guard let range = view.selectedTextRange else {
                return nil
            }
            let caretRect = view.caretRect(for: range.end)
            let windowRect = view.convert(caretRect, to: nil)
            return windowRect.origin.y + windowRect.height
        }
        
    }
}

enum Keyboard {
    
    static let willShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .receive(on: OperationQueue.main)
    
    static let didShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardDidShowNotification)
        .receive(on: OperationQueue.main)
    
    static let willHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .receive(on: OperationQueue.main)
    
    static let didHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardDidHideNotification)
        .receive(on: OperationQueue.main)
    
    static let willChangeFrame = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        .receive(on: OperationQueue.main)
    
    static let didChangeFrame = NotificationCenter.default
        .publisher(for: UIResponder.keyboardDidChangeFrameNotification)
        .receive(on: OperationQueue.main)
}

public extension Notification {
    
    var keyboardRectBegin: CGRect {
        return (userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    }

    var keyboardRectEnd: CGRect {
        return (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    }
    
    var keyboardGoesDown: Bool {
        let beginY = keyboardRectBegin.origin.y
        let endY = keyboardRectEnd.origin.y
        return beginY < endY
    }
    
    var keyboardGoesUp: Bool {
        return !keyboardGoesDown
    }

    var keyboardHeight: CGFloat {
        if keyboardGoesDown { // going down
            return 0
        } else { // otherwise
            return keyboardRectEnd.size.height
        }
    }
    
    var keyboardAnimationDuration: Double {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
    }

    var keyboardAnimationOptions: UIView.AnimationOptions {
        if let curveValue = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue {
            return [UIView.AnimationOptions(rawValue: curveValue << 16), .beginFromCurrentState]
        }
        return []
    }
}

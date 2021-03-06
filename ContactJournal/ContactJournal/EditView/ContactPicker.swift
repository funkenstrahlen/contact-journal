//
//  ContactPicker.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 17.10.20.
//

import Foundation
import ContactsUI

protocol EmbeddedContactPickerViewControllerDelegate: class {
    func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController)
    func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contact: CNContact)
}

class EmbeddedContactPickerViewController: UIViewController, CNContactPickerDelegate {
    weak var delegate: EmbeddedContactPickerViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.open(animated: animated)
    }

    private func open(animated: Bool) {
        let viewController = CNContactPickerViewController()
        viewController.delegate = self
        self.present(viewController, animated: false)
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewControllerDidCancel(self)
        }
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewController(self, didSelect: contact)
        }
    }

}

import SwiftUI
import Contacts
import Combine

struct ContactPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = EmbeddedContactPickerViewController
    
    @Binding var showPicker: Bool
    public var onSelectContact: ((_: CNContact) -> Void)

    final class Coordinator: NSObject, EmbeddedContactPickerViewControllerDelegate {
        var parent : ContactPicker
        
        init(_ parent: ContactPicker){
            self.parent = parent
        }
        
        func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contact: CNContact) {
            parent.onSelectContact(contact)
            parent.showPicker = false
        }

        func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController) {
            parent.showPicker = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPicker>) -> ContactPicker.UIViewControllerType {
        let result = ContactPicker.UIViewControllerType()
        result.delegate = context.coordinator
        return result
    }

    func updateUIViewController(_ uiViewController: ContactPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<ContactPicker>) { }

}

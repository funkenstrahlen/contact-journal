//
//  AktivityController.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 21.10.20.
//

import UIKit
import SwiftUI

struct ShareExportActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    var completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareExportActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = completionWithItemsHandler
        controller.excludedActivityTypes = [.addToReadingList, .assignToContact, .openInIBooks, .postToFlickr, .postToTencentWeibo, .postToTwitter, .postToVimeo, .postToWeibo, .saveToCameraRoll]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareExportActivityViewController>) {}

}

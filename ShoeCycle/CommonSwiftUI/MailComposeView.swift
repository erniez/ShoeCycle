//  MailComposeView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/30/23.
//  
//

import SwiftUI
import MessageUI
import OSLog

struct MailComposeView: UIViewControllerRepresentable {
    let shoe: Shoe
    let mailDelegate = MailComposeViewDelegate()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let csvUtility = CSVUtility()
        let csvString = csvUtility.createCSVData(fromShoe: shoe)
        let csvData = csvString.data(using: NSUTF8StringEncoding)!
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = mailDelegate
        mailViewController.setSubject("CSV data from ShoeCycle shoe: \(shoe.brand ?? "N/A")")
        mailViewController.addAttachmentData(csvData,
                                             mimeType: "text/csv",
                                             fileName: "ShoeCycleShoeData-\(shoe.brand ?? "").csv")
        mailViewController.setMessageBody("Attached is the CSV shoe data from ShoeCycle!",
                                          isHTML: false)
        return mailViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    static func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
}

final class MailComposeViewDelegate: NSObject,  MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
            
        case .cancelled:
            Logger.app.error("Mail cancelled: you cancelled the operation and no email message was queued.")
        case .saved:
            Logger.app.info("Mail saved: you saved the email message in the drafts folder.")
        case .sent:
            Logger.app.info("Mail send: the email message is queued in the outbox. It is ready to send.")
        case .failed:
            Logger.app.error("Mail failed: the email message was not saved or queued, possibly due to an error.")
        @unknown default:
            Logger.app.error("Mail not sent for an unknown reason.")
        }
        
        controller.dismiss(animated: true)
    }
}

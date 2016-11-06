//
//  EmailUtility.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/27/16.
//
//

import Foundation
import MessageUI


class EmailUtility: NSObject {

    /**
     This returns a fresh MFMailComposeViewController if mail is available, if not, it returns an UIAlertController.
    */
    func newMailComposerViewController()-> UIViewController {
        if MFMailComposeViewController.canSendMail() {
            return MFMailComposeViewController()
        }
        
        let alertController = UIAlertController(title: "Email Failure", message: "Your device does not support email.", preferredStyle:UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil)
        alertController.addAction(defaultAction)
        return alertController
    }
}
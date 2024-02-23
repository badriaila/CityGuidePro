//
//  EmailPopUpVC.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit
import MessageUI

class EmailPopUpVC: UIViewController, MFMailComposeViewControllerDelegate{
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    @IBOutlet weak var CancelButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func submitBtnAction(_ sender: Any) {
        
            let mailComposeViewController = configureMailController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                showMailError()
            }
        
            
 //           sendEmail(recipient: ["wsuaccesslab@gmail.com"], text: "Congradulations")
    }
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["wsuaccesslab@gmail.com"])
        mailComposerVC.setSubject("Regarding CityGuide")
        mailComposerVC.setMessageBody("I just tried using it.", isHTML: false)

        return mailComposerVC
    }

    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendEmail(recipient: [String], text: String)
        {
            if MFMailComposeViewController.canSendMail()
            {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(recipient)
                mail.setMessageBody(text, isHTML: false)
                
                present(mail, animated: true, completion: nil)
            }
            else
            {
                //failure
            }
        }
   
    
    @IBAction func CancelBtnClicked(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

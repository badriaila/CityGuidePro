//
//  ViewController.swift
//  SampleEdit1
//
//  Created by wh-308 on 4/12/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row]
        
        // Set the selected contact as the default for the corresponding button
        switch selectedContact.type {
        case .audio:
            audioCallDefaultContact = selectedContact
        case .video:
            videoCallDefaultContact = selectedContact
        case .message:
            messageDefaultContact = selectedContact
        }
        
        // Save the defaults to user defaults
        saveDefaults()
        
        // Deselect the selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Save the updated contacts to user defaults
            saveContacts()
            
            // If the deleted contact was a default, remove it from the corresponding default
            let deletedContact = contacts[indexPath.row]
            if audioCallDefaultContact == deletedContact {
                audioCallDefaultContact = nil
                saveDefaults()
            }
            if videoCallDefaultContact == deletedContact {
                videoCallDefaultContact = nil
                saveDefaults()
            }
            if messageDefaultContact == deletedContact {
                messageDefaultContact = nil
                saveDefaults()
            }
        }
    }


}


//
//  ViewController.swift
//  editContact
//
//  Created by wh-308 on 4/12/23.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var editContactButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editContactButtonTapped(_ sender: UIButton) {
            let contactListViewController = ContactListViewController()
            let navigationController = UINavigationController(rootViewController: contactListViewController)
            present(navigationController, animated: true, completion: nil)
        }


}


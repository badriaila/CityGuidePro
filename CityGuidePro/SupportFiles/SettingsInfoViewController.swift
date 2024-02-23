//
//  SettingsInfoViewController.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit

class SettingsInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   

   
    @IBAction func buttonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "mySegueIdentifier", sender: self)

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

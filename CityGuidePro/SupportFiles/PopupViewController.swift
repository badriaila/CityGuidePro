// Updated by AJ

import UIKit

class PopupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a background view that covers the entire screen
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(backgroundView)
        
        // Create a pop-up view in the center of the screen
        let popupView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        popupView.backgroundColor = UIColor.white
        popupView.layer.cornerRadius = 10
        popupView.center = view.center
        view.addSubview(popupView)
    }
}

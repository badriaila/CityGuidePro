//
//  HomeVC.swift
//  CityGuidePro
//
//  Updated by AJ

import UIKit
import CoreLocation
import AVFoundation
import CoreHaptics
import Speech
import MessageUI

class HomeVC: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate, BeaconScannerDelegate, MFMailComposeViewControllerDelegate, UITabBarControllerDelegate {
    
    
    @IBOutlet weak var naratorMute: UIButton!
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var compassLabel: UILabel!
    //    @IBOutlet weak var searchBar: UISearchBar!
    //    @IBOutlet weak var searchBarPosition: NSLayoutConstraint!
    @IBOutlet weak var compassImage: UIImageView!
    @IBOutlet weak var floorPlan: UIImageView!
    @IBOutlet var floorPlanScrollView: UIScrollView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet var instrLabel: UILabel!
    
    @IBOutlet weak var feedbackBtn: UIButton!
    @IBOutlet weak var textSearchBtn: UIButton!
    @IBOutlet weak var exitsBtn: UIButton!
    @IBOutlet weak var restroomsBtn: UIButton!
    
    
    
    let userDefaults = UserDefaults.standard
    
    var beaconScanner: BeaconScanner!
    var beaconManager : CLLocationManager?
    var locationManager : CLLocationManager?
    var userDefinedRssi: Float = 0.0
    var beaconList : [Int] = []
    var detectedGroupId = -1
    var groupID : Int = -1
    var floorNo : Int = -10
    var CURRENT_NODE = -1
    var CLOSEST_RSSI = -100000.0
    var FARTHEST_NODE = -1
    var userAngle : Double = -1
    var atBeaconInstr : [Int : String] = [:]
    var poiAtCurrentNode : [Int:String] = [:]
    
    let srVC = SearchResultsVC()
    let erVC = ExitsViewController()
    let rrVC = RestroomsViewController()

    let narator = AVSpeechSynthesizer()
    var currentlyAt = -1
    var engine: CHHapticEngine?
    var speechRecognizer = SpeechRecognizer()
    var timer : Timer?
    var new_timer : Timer?
    var window : [Int : [Int]] = [:]
    let group = DispatchGroup()
    
    //Flags
    var newGroupNoticed = false
    var getBeaconsFlag = false
    var getThePath = false
    var speechFlag = false
    var recursionFlag = false
    var indoorWayFindingFlag = false
    var isOnRoute = false
    var stopRepeatsFlag = true
    var explorationFlag = true
    var userResponse = false
    var voiceSearchFlag = false
    var muteFlag = false
    var allowDot = false
    var searchListResetFlag = false
    var isZoomedIn = false


    deinit {
    // Invalidate the timer when the view controller is deinitialized
    timer?.invalidate()
    }

    
    
    @objc func buttonDown(_ sender: UIButton) {     // May not be in use
        singleFire(check: nil)
    }
    
    @objc func buttonUp(_ sender: UIButton) {       // May not be in use
        timer?.invalidate()
    }
    



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        // To set the order for VoiceOver to read out the view elements.
        // should use view.accessibilityElements = [] instead of accessibilityElements = []
        view.accessibilityElements = [
            floorPlan,
            stopBtn,
            compassLabel,
            textSearchBtn,
            recButton,
            exitsBtn,
            restroomsBtn,
            feedbackBtn
          ].compactMap { $0 }
        
        
    
        
        // the user category screen...if a user category is not selected, the app crashes in nav mode when using app for the first time
        // making selection using Nandha's window options dont seem to help
        // firstOpen()
        
        

        // welcome text for label
        self.instrLabel.text = "CityGuide 2.0"
        self.instrLabel.font = UIFont(name: "HelveticaNeue-Light", size: 19.0)
        self.instrLabel.textColor = UIColor.systemYellow
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            
            self.instrLabel.text = nil

        }
        
        // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))

        tapGesture.numberOfTapsRequired = 1
        floorPlan.addGestureRecognizer(tapGesture)
        
        
        
        

        // to ZOOM IN on floor plan image
        floorPlan.isUserInteractionEnabled = true
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
        floorPlan.addGestureRecognizer(pinchGesture)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))

        // to ZOOM IN on floor plan image automatically
//          scrollView.minimumZoomScale = 1.0
//             var scrollView = UIScrollView()
//             scrollView.minimumZoomScale = 1.0
//             // Additional setup for the scrollView
// //
//             scrollView.maximumZoomScale = 6.0
// //            scrollView.addSubview(floorPlan)
//             scrollView.delegate = self
//             scrollView.contentSize = floorPlan.frame.size



        
        
        
        
        narator.delegate = self
        
        /* Nandha's
        speakThis(sentence: "Home")
        if let tabBarController = self.tabBarController {
                    tabBarController.delegate = self
                }
        if let usernameStr = userDefaults.string(forKey: "myUserNameKey") {
            userNameLabel.text = "Hello \(usernameStr)!"
        }
        //        beaconManager = CLLocationManager()
        //        beaconManager?.delegate = self
        //        beaconManager?.requestAlwaysAuthorization()
        */
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingHeading()
        
        becomeFirstResponder()
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            do {
                engine = try CHHapticEngine()
                try engine?.start()
            } catch {
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
        }
        
        if let userInputs = UserDefaults.standard.value(forKey: "userInputItems") as? [String : Float]{
            userDefinedRssi = userInputs["Set Threshold"] ?? (-80.00)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        recButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        recButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        
        self.beaconScanner = BeaconScanner()
        self.beaconScanner!.delegate = self
        self.beaconScanner!.startScanning()
        
        self.naratorMute.setImage(UIImage(systemName: "volume.fill"), for: .normal)
        self.naratorMute.tintColor = .black
        self.recButton.tintColor = .black
        self.stopBtn.tintColor = .black
        
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCoordinates), userInfo: nil, repeats: true)
        // Check if floorPlan is not nil
        floorPlan.contentMode = .scaleAspectFit

        // DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
        //     self.addFloorplanSubview()
        // }
    }


   
 @objc func updateCoordinates() {
    // Update currentUserCoordinates
    var currentUserCoordinates = extractCoordinates(currNode: self.CURRENT_NODE)
    print("Current user coordinates: \(currentUserCoordinates)")

    // Update the zoom level and center on the specified pixel coordinates
    if isZoomedIn{
        zoomInAtUserLocation(axis: currentUserCoordinates)
    }    
}

@objc func handleTapGesture(_ sender: UITapGestureRecognizer){
    isZoomedIn = !isZoomedIn

    if !isZoomedIn{
        // If the view is zoomed in, zoom out
            UIView.animate(withDuration: 0.3, animations: {
                self.floorPlan.transform = CGAffineTransform.identity
            })
    }
}

// @objc func addFloorplanSubview() {
//     // Initialize the scroll view and the image view
//     floorPlanScrollView = UIScrollView()
//     floorPlanScrollView.translatesAutoresizingMaskIntoConstraints = false
//     floorPlan.contentMode = .scaleAspectFit
//     floorPlan.translatesAutoresizingMaskIntoConstraints = false

//     // Add the image view to the scroll view
//     floorPlanScrollView.addSubview(floorPlan)

//     // Set up the scroll view for zooming
//     floorPlanScrollView.delegate = self
//     floorPlanScrollView.minimumZoomScale = 1.0
//     floorPlanScrollView.maximumZoomScale = 2.0

//     // Add the scroll view to the view hierarchy
//     view.addSubview(floorPlanScrollView)

//     // Set the constraints for the scroll view
//     NSLayoutConstraint.activate([
//         floorPlanScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//         floorPlanScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//         floorPlanScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//         floorPlanScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
//     ])

//     // Set the constraints for the image view
//     NSLayoutConstraint.activate([
//         floorPlan.topAnchor.constraint(equalTo: floorPlanScrollView.topAnchor),
//         floorPlan.bottomAnchor.constraint(equalTo: floorPlanScrollView.bottomAnchor),
//         floorPlan.leadingAnchor.constraint(equalTo: floorPlanScrollView.leadingAnchor),
//         floorPlan.trailingAnchor.constraint(equalTo: floorPlanScrollView.trailingAnchor),
//         floorPlan.widthAnchor.constraint(equalTo: floorPlanScrollView.widthAnchor),
//         floorPlan.heightAnchor.constraint(equalTo: floorPlanScrollView.heightAnchor)
//     ])
// }

func zoomInAtUserLocation(axis: [Int]) {

    print(axis)
    

//    let randomNumber1 = Int.random(in: 1...1100)
//    let randomNumber2 = Int.random(in: 1...2000)
     let imagePixelCoordinates = CGPoint(x: axis[0], y: axis[1])  // Replace with your pixel coordinates
//    let imagePixelCoordinates = CGPoint(x: randomNumber1, y: randomNumber2)  // Replace with your pixel coordinates
    
    let viewCoordinates = CGPoint(x: imagePixelCoordinates.x * floorPlan.bounds.size.width / floorPlan.image!.size.width,
                                     y: imagePixelCoordinates.y * floorPlan.bounds.size.height / floorPlan.image!.size.height)
   
    let tapCenter = CGPoint(x: viewCoordinates.x - view.bounds.midX + 74.0,
                                y: viewCoordinates.y - view.bounds.midY + 237.0)

    print("viewCoordinates: \(viewCoordinates)")
    print(view.bounds.midX, view.bounds.midY)
    print(tapCenter)

       
            // If the view is not zoomed in, zoom in
            let newScale: CGFloat = 2.0  // Set this to the scale you want to zoom to

//            let transform = floorPlan.transform.translatedBy(x: viewCoordinates.x, y: viewCoordinates.y).scaledBy(x: newScale, y: newScale)
            
             let transform = view.transform.translatedBy(x: tapCenter.x, y: tapCenter.y)
                                           .scaledBy(x: newScale, y: newScale)
                                           .translatedBy(x: -tapCenter.x, y: -tapCenter.y)

            UIView.animate(withDuration: 0.3, animations: {
                self.floorPlan.transform = transform
            })
        
    }

// func zoomInAtUserLocation(axis: [Int]) {
//     print(axis)
    
//     let imagePixelCoordinates = CGPoint(x: axis[0], y: axis[1])  // Replace with your pixel coordinates
//     let viewCoordinates = CGPoint(x: imagePixelCoordinates.x * floorPlan.bounds.size.width / floorPlan.image!.size.width,
//                                   y: imagePixelCoordinates.y * floorPlan.bounds.size.height / floorPlan.image!.size.height)
   
//     // let tapCenter = CGPoint(x: viewCoordinates.x - view.bounds.midX + 74.0,
//     //                         y: viewCoordinates.y - view.bounds.midY + 237.0)

//     let tapCenter = CGPoint(x: viewCoordinates.x, y: viewCoordinates.y)


//     print("viewCoordinates: \(viewCoordinates)")
//     print(view.bounds.midX, view.bounds.midY)
//     print(tapCenter)

//     // If the view is not zoomed in, zoom in
//     let newScale: CGFloat = 2.0  // Set this to the scale you want to zoom to

//     // Calculate the offset for the zoom
//     let offsetX = (view.bounds.width - floorPlan.bounds.width * newScale) / 2.0
//     let offsetY = (view.bounds.height - floorPlan.bounds.height * newScale) / 2.0

//     // Create the transformation
//     let transform = CGAffineTransform(translationX: offsetX, y: offsetY)
//         .scaledBy(x: newScale, y: newScale)
//         .translatedBy(x: -tapCenter.x, y: -tapCenter.y)

//     UIView.animate(withDuration: 0.3, animations: {
//         self.floorPlan.transform = transform
//     })
// }

// func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//     return floorPlan
// }

// func zoomInAtUserLocation(axis: [Int]) {
//   let imagePixelCoordinates = CGPoint(x: axis[0], y: axis[1])
//     let viewCoordinates = CGPoint(x: imagePixelCoordinates.x * floorPlan.bounds.size.width / floorPlan.image!.size.width,
//                                   y: imagePixelCoordinates.y * floorPlan.bounds.size.height / floorPlan.image!.size.height)

//     let scrollViewSize = floorPlanScrollView.bounds.size
//     let widthScale = scrollViewSize.width / floorPlan.image!.size.width
//     let heightScale = scrollViewSize.height / floorPlan.image!.size.height
//     let minScale = min(widthScale, heightScale)

//     let finalScale = minScale * 2.0 // Adjust the 2.0 to the zoom level you want
//     let finalX = viewCoordinates.x * finalScale - scrollViewSize.width / 2
//     let finalY = viewCoordinates.y * finalScale - scrollViewSize.height / 2
//     let finalPoint = CGPoint(x: finalX, y: finalY)

//     UIView.animate(withDuration: 0.3, animations: {
//         self.floorPlanScrollView.zoomScale = finalScale
//         self.floorPlanScrollView.contentOffset = finalPoint
//     })
// }


   
    
//    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
//     guard let view = sender.view else { return }

//     let currentUserCoordinates = extractCoordinates(currNode: self.CURRENT_NODE)
//     let imagePixelCoordinates = CGPoint(x: currentUserCoordinates[0], y: currentUserCoordinates[1])  // Replace with your pixel coordinates
//        let viewCoordinates = CGPoint(x: imagePixelCoordinates.x * floorPlan.bounds.size.width / floorPlan.image!.size.width,
//                                      y: imagePixelCoordinates.y * floorPlan.bounds.size.height / floorPlan.image!.size.height)
//     print(currentUserCoordinates)
//     print(viewCoordinates)

//     if sender.state == .ended {
//         let tapCenter = CGPoint(x: viewCoordinates.x - view.bounds.midX,
//                                 y: viewCoordinates.y - view.bounds.midY)

//         print(view.bounds.midX, view.bounds.midY)
//         print("tapCenter: \(tapCenter)")
        
//         if isZoomedIn {
//             // If the view is zoomed in, zoom out
//             UIView.animate(withDuration: 0.3, animations: {
//                 self.floorPlan.transform = CGAffineTransform.identity
//             })
//         } else {
//             // If the view is not zoomed in, zoom in
//             let newScale: CGFloat = 2.0  // Set this to the scale you want to zoom to

// //            let transform = floorPlan.transform.translatedBy(x: viewCoordinates.x, y: viewCoordinates.y).scaledBy(x: newScale, y: newScale)
            
//              let transform = view.transform.translatedBy(x: tapCenter.x, y: tapCenter.y)
//                                            .scaledBy(x: newScale, y: newScale)
//                                            .translatedBy(x: -tapCenter.x, y: -tapCenter.y)

//             UIView.animate(withDuration: 0.3, animations: {
//                 self.floorPlan.transform = transform
//             })
//         }

//         // Toggle the isZoomedIn property
//         isZoomedIn = !isZoomedIn
//     }
// }


   
     


    
    // function to ZOOM IN on floor plan image
    @objc func pinchGesture(sender:UIPinchGestureRecognizer){
        /* // trial 1
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
        */
        
        /* // trial 2...to automatically go back to original size after pinch gesture ends
        if sender.state == .changed {
            let currentScale = self.floorPlan.frame.size.width / self.floorPlan.bounds.size.width
            var newScale = currentScale*sender.scale
            
            if newScale < 1{
                newScale = 1
            }
            
            if newScale > 4 {
                newScale = 4
            }
            
            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            
            self.floorPlan.transform = transform
            
            sender.scale = 1
        }
        else if sender.state == .ended{
            UIView.animate(withDuration: 0.3, animations: {
                self.floorPlan.transform = CGAffineTransform.identity
            })
        }
        */
        
        // trial 3....to pinch at a specific location on image to ZOOM in on to that location and
        // then to automatically go back to original size after pinch gesture ends
        if sender.state == .changed {
            
            guard let view = sender.view else {return}
            
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
            y: sender.location(in: view).y - view.bounds.midY)
            
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
            .scaledBy(x: sender.scale, y: sender.scale)
            .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            let currentScale = self.floorPlan.frame.size.width / self.floorPlan.bounds.size.width
            
            var newScale = currentScale*sender.scale
            
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.floorPlan.transform = transform
                sender.scale = 1
            }
            
            else {
                view.transform = transform
                sender.scale = 1
            }
        }
        else if sender.state == .ended{
            UIView.animate(withDuration: 0.3, animations: {
                self.floorPlan.transform = CGAffineTransform.identity
            })
        }
        
    }



    
    

    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {   // When app shake is detected run the doubletap method
        if motion == .motionShake {
            doubleTapped()
        }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
           
           //let homeVC = HomeVC()
           let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController)
        
        if(selectedIndex == 0){
            speakThis(sentence: "Home")
        }else if(selectedIndex == 1){
            speakThis(sentence: "Contacts")
        }else{
            speakThis(sentence: "Settings")
        }
    

               // Handle the case where the view controller isn't found
           
          
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let usernameStr = userDefaults.string(forKey: "myUserNameKey") {
            userNameLabel.text = "Hello, \(usernameStr)!"
        }
        // Hides the stop icon
        stopBtn.isHidden = true
        stopLabel.isHidden = true
    }
    
    
    
    
    func getDirection(angl : Double) -> String{
        if (angl < 22.5 || angl >= 337.5){
            return "N"
        }
        if (angl >= 22.5 && angl < 67.5){
            return "NE"
        }
        if (angl >= 67.5 && angl < 112.5){
            return "E"
        }
        if (angl >= 112.5 && angl < 157.5){
            return "SE"
        }
        if (angl >= 157.5 && angl < 202.5){
            return "S"
        }
        if (angl >= 202.5 && angl < 247.5){
            return "SW"
        }
        if (angl >= 247.5 && angl < 292.5){
            return "W"
        }
        if (angl >= 292.5 && angl < 337.5){
            return "NW"
        }
            
        return "Error"
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {    // Gets angle of user
        UIView.animate(withDuration: 0.5) {
            let angle = newHeading.trueHeading    // true heading is the heading (mesured in degrees)     relative to true North
            //let degToRad = angle * .pi / 180               // to convert degrees to radians
            //let degrees = angle * 180 / .pi         // to convert radians to degrees
            self.userAngle = angle                  // this line is very important...it updates our orientation to align with the direction we are turning in our current position
//            print("Direction: " + String(angle))
//            print("Direction: " + String(degrees))
//            print("Direction: " + String(rad))
            //self.compassImage.transform = CGAffineTransform(rotationAngle: -degToRad)
            
            //self.compassLabel.textColor = UIColor.systemYellow
            self.compassLabel.textColor = UIColor(red: (255/255.0), green: (225/255.0), blue: (102/255.0), alpha: 1.0)
            //self.compassLabel.layer.borderColor = UIColor.systemYellow.cgColor
            self.compassLabel.layer.borderColor = UIColor(red: (255/255.0), green: (225/255.0), blue: (102/255.0), alpha: 1.0).cgColor
            self.compassLabel.layer.borderWidth = 1.0
            self.compassLabel.layer.cornerRadius = 10
            self.compassLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
            self.compassLabel.text = String(Int(angle)) + "° " + self.getDirection(angl: angle)
            
        }
    }
    
    // This was used for ibeacon only hence commented out <-----
    //    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    //        switch manager.authorizationStatus{
    //            case .authorizedAlways, .authorizedWhenInUse:
    //                print("Authorized")
    //                if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
    //                    if CLLocationManager.isRangingAvailable(){
    //                        startScanning()
    //                    }
    //                }
    //            case .notDetermined:
    //                let alert = UIAlertController.init(title: "Cannot Find Beacons", message: "Permissions were undetermined.", preferredStyle: .alert)
    //                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
    //                self.present(alert, animated: true, completion: nil)
    //            case .restricted:
    //                let alert = UIAlertController.init(title: "Cannot Find Beacons", message: "Permissions were restricted.", preferredStyle: .alert)
    //                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
    //                self.present(alert, animated: true, completion: nil)
    //            case .denied:
    //                let alert = UIAlertController.init(title: "Cannot Find Beacons", message: "Permissions were denied.", preferredStyle: .alert)
    //                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
    //                self.present(alert, animated: true, completion: nil)
    //            @unknown default:
    //                let alert = UIAlertController.init(title: "Cannot Find Beacons", message: "Permissions were denied.", preferredStyle: .alert)
    //                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
    //                self.present(alert, animated: true, completion: nil)
    //        }
    //    }
    
    //    func startScanning(){
    //        let uuid = UUID.init(uuidString: "CA1D78EA-BE1A-4580-8D87-1F60B67A80AB")!
    //        let beaconRegion = CLBeaconRegion.init(uuid: uuid, major: 0, identifier: "Gimbal Beacon")
    //        let beconIdConstraint = CLBeaconIdentityConstraint.init(uuid: uuid)
    //        beaconManager?.startMonitoring(for: beaconRegion)
    //        beaconManager?.startRangingBeacons(satisfying: beconIdConstraint)
    //    }
    //
    func firstOpen() {
        let vc = self.storyboard?.instantiateViewController(identifier: "firstScreenVC") as! firstScreenVC
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    func didFindBeacon(beaconScanner: BeaconScanner, beaconInfo: BeaconInfo) {
        //NSLog("FIND: %@", beaconInfo.description)
        callOperations(beaconScanner: beaconScanner, beaconInfo: beaconInfo)
    }
    
    func didLoseBeacon(beaconScanner: BeaconScanner, beaconInfo: BeaconInfo) {
        //NSLog("LOST: %@", beaconInfo.description)
    }
    func didUpdateBeacon(beaconScanner: BeaconScanner, beaconInfo: BeaconInfo) {
        //NSLog("UPDATE: %@", beaconInfo.description)
        callOperations(beaconScanner: beaconScanner, beaconInfo: beaconInfo)
    }
    
    func callOperations(beaconScanner: BeaconScanner, beaconInfo: BeaconInfo){
        if userDefinedRssi == 0.0{
            userDefinedRssi = -80.0
        }
        // trial trial...changed beaconInfo.RSSI < -45 to beaconInfo.RSSI > -74
        if(beaconInfo.RSSI >= Int(userDefinedRssi) && beaconInfo.RSSI < -50 && beaconInfo.RSSI > -74){
            if(window[beaconInfo.beaconID.bID] == nil){
                let arr = [beaconInfo.RSSI]
                window[beaconInfo.beaconID.bID] = arr
            }
            else{
                var arr = window[beaconInfo.beaconID.bID]
                if arr!.count >= 4{
                    arr?.remove(at: 0)
                }
                arr?.append(beaconInfo.RSSI)
                window[beaconInfo.beaconID.bID] = arr
                for i in window.keys{
                    if window[i] != arr{
                        if window[i]!.count >= 4{
                            window[i]?.remove(at: 0)
                        }
                        window[i]!.append(-100)
                    }
                }
            }
        }
        
        checkWindow()
        
        if(CURRENT_NODE != -1 && CLOSEST_RSSI > Double(userDefinedRssi)){
            updateBeaconReading(distance: CLOSEST_RSSI, beacon: CURRENT_NODE)
        }
    }
    
    func didObserveURLBeacon(beaconScanner: BeaconScanner, URL: NSURL, RSSI: Int) {
        //do nothing here
    }
    
    // Screening window code and functions
    // ===================================
    func checkWindow(){
        var maxNumOfDetection = 0
        var singleRssiArray = 0
        var doubleRssiArray = 0
        print("==========================================")
        for i in window.keys{
            print(String(i), terminator: ": ")
            print(window[i]!)
            maxNumOfDetection+=1
        }
        print("==========================================")
        if(maxNumOfDetection > 5){
            for i in window.keys{
                let checker = window[i]!;
                var sum = 0
                for i in checker{
                    sum += i
                }
                
                if(checker.count == 1){
                    singleRssiArray+=1
                }
                if(checker.count == 2){
                    doubleRssiArray+=1
                }
                
                if Float(sum/checker.count) < userDefinedRssi{
                    window.removeValue(forKey: i)
                }
                if !listOfBeacon.contains(i){
                    window.removeValue(forKey: i)
                }
            }
        }
        
        if(singleRssiArray > 3 || doubleRssiArray > 3){
            for i in window.keys{
                let checker = window[i]!
                if(checker.count == 1 && singleRssiArray > 3){
                    window.removeValue(forKey: i)
                }
                if(checker.count == 2 && doubleRssiArray > 3){
                    window.removeValue(forKey: i)
                }
            }
        }
        maxNumOfDetection = 0
        screeningWindow()
    }
    
    func screeningWindow(){
        var closestRssi = -100000.0
        var closestBeacon = 0
        var farthestBeacon = 0
        var farthestRssi = 100000.0
        for i in window.keys{
            let arr = window[i]
            let arrSize = arr?.count
            var numerator = 0
            
            if(arrSize! >= 4){
                var weight = arrSize!
                
                for vector in arr!{
                    numerator = numerator + (-1 * vector * (weight))
                    weight-=1
                }
                var denominator = 0
                for w in 1...arrSize!{
                    denominator += w
                }
                
                let temp = closestRssi
                let far = farthestRssi
                
                closestRssi = max(closestRssi, -1.0 * Double(numerator / denominator))
                farthestRssi = min(farthestRssi, -1.0 * Double(numerator / denominator))
                
                if closestRssi != temp{
                    closestBeacon = i
                }
                if farthestRssi != far{
                    farthestBeacon = i
                }
            }
        }
        
        if(closestBeacon != 0){
            CURRENT_NODE = closestBeacon
            CLOSEST_RSSI = closestRssi
            FARTHEST_NODE = farthestBeacon
        }
        if FARTHEST_NODE != -1 && CURRENT_NODE != FARTHEST_NODE{
            window.removeValue(forKey: FARTHEST_NODE)
        }
        
        // -1 indicates that no group has been assigned yet
        if(groupID == -1){
            newGroupNoticed = true
        }
        
        //Nandha's
        userDefaults.set(CURRENT_NODE, forKey: "CURRENT_NODE_key")
        userDefaults.set(groupID, forKey: "groupID_key")


        // For the closest beacon found, CURRENT_NODE is its beacon id, CLOSEST_RSSI is its RSSI and groupID is its group id
        print("Closest Beacon : " + String(CURRENT_NODE) + " Rssi : " + String(CLOSEST_RSSI) + " Group : " + String(groupID))
        
        // trial trial...seems like the only thing this does is correctly identify the group ID of the closest beacon it detected...no effect on floor plan image
        for i in dArray{    // to match groupid and floorplan
            if i["beacon_id"] as! Int == CURRENT_NODE{
                if let checkerForHub = i["locname"] as? String{
                    if checkerForHub.contains("Hub "){
                        let n = i["group_id"] as? Int
                        if n != groupID{
                            newGroupNoticed = true
                            break
                        }
                        let flr = i["_level"] as? Int
                        
                        // trial trial
                        if flr != floorNo{
                            floorNo = flr!
                            allowDot = false
                            // guess this one's used when group ID is the same but floor number has changed when moving from one beacon to another
                            postToDB(typeOfAction: "getFloor", beaconID: groupID, auth: "eW7jYaEz7mnx0rrM", floorNum: floorNo, vc: self)
                            DispatchQueue.main.async {
                                if image != nil && self.floorPlan.image != image && !self.allowDot{
                                    self.floorPlan.image = image
                                    self.allowDot = true
                                }
                            }
                            break
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            ////////////////////////////////////////////////////////////////////////////////
            // when NAVIGATION MODE is NOT ACTIVE
            ////////////////////////////////////////////////////////////////////////////////
            if(self.CURRENT_NODE != -1 && self.floorPlan.image != nil && !self.indoorWayFindingFlag){
                
                let coordinates = extractCoordinates(currNode: self.CURRENT_NODE)
                if(!coordinates.isEmpty && image != nil){
                    
                    // ORIGINAL
                    self.floorPlan.image = image
                    self.floorPlan.image = drawOnImage(self.floorPlan.image!, x: coordinates[0], y: coordinates[1])
                }
            }
            
            // trial trial
            ////////////////////////////////////////////////////////////////////////////////
            // when NAVIGATION MODE is ACTIVE
            ////////////////////////////////////////////////////////////////////////////////
            if(self.indoorWayFindingFlag){
                
                let coordinates = extractCoordinates(currNode: self.CURRENT_NODE)
                if(!coordinates.isEmpty && image != nil){
                    

                    self.floorPlan.image = image
                    self.floorPlan.image = drawOnImage2(self.floorPlan.image!, groupID: self.groupID, floorNo: self.floorNo, shortestPath: shortestPath, xCord: coordinates[0], yCord: coordinates[1])
                }
                

                
                
                
            }
        }
    }

    
    
    
    
    
    func updateBeaconReading(distance : Double, beacon: Int){       // Talks to the server a lot, and calls modes....here, distance is closest RSSI, beacon is the current beacon id
        
        if beacon != -1{
            if beaconList.contains(beacon) == false{
                beaconList.append(beacon)
                postToDB(typeOfAction: "beacons", beaconID: beacon, auth: "eW7jYaEz7mnx0rrM", floorNum: nil, vc: self)
            }
        }
        
        if dArray.count != 0 && newGroupNoticed{
            for i in dArray{    // to match groupid and floorplan
                if i["beacon_id"] as! Int == CURRENT_NODE{
                    if let checkerForHub = i["locname"] as? String{
                        if checkerForHub.contains("Hub "){
                            let n = i["group_id"] as? Int
                            if n != groupID{
                                groupID = n!
                            }
                            
                            
                            // trial trial
                            //if detectedGroupId != groupID && detectedGroupId != -1{
                            //    detectedGroupId = groupID
                            //    groupChangeNoticed()                // Call to get reset matrix values
                            //}
                            
                            
                            

                            if let v = i["_level"] as? Int{
                                // trial trial....changed 'if floorNo != v' to 'if floorNo == v'
                                // trial trial....comment it out and see if any change
                                if floorNo != v{
                                    floorNo = v
                                    postToDB(typeOfAction: "getFloor", beaconID: groupID, auth: "eW7jYaEz7mnx0rrM", floorNum: floorNo, vc: self)
                                }
                            }
                            break
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            if image != nil && self.floorPlan.image != image && !self.allowDot{
                self.floorPlan.image = image
                self.allowDot = true
            }
        }
        
        if groupID != -1 && newGroupNoticed && floorNo != -10{
            // get all the beacons for the new group.
            print("Group ID set: \(groupID)")
            self.allowDot = false
            
            //trial trial
            //listOfBeacon.removeAll()
            //destinations.removeAll()
            //matrixDictionary.removeAll()
            
            postToDB(typeOfAction: "getbeacons", beaconID: groupID, auth: "eW7jYaEz7mnx0rrM", floorNum: floorNo, vc: self)
            newGroupNoticed = false
            getBeaconsFlag = true
            searchListResetFlag = true
        }
        
        if getBeaconsFlag && !listOfBeacon.isEmpty{ // get all values of the new set of beacons
            
            //trial trial
            //dArray.removeAll()
            //beaconList.removeAll()
            
            for i in listOfBeacon{
                if !beaconList.contains(i){
                    beaconList.append(i)
                    postToDB(typeOfAction: "beacons", beaconID: i, auth: "eW7jYaEz7mnx0rrM", floorNum: nil, vc: self)
                }
            }
            
            if(explorationFlag){
                speechFlag = true
                recursionFlag = false
            }
            getBeaconsFlag = false
        }
        
        if destinations.count != srVC.locations.count || searchListResetFlag{
            srVC.getLocations(values: destinations)
            erVC.getLocations(values: destinations)
            rrVC.getLocations(values: destinations)
            searchListResetFlag = false
        }
        
        if pathFound{
            print("Path Found!")
            for i in dArray{
                if i["beacon_id"] as! Int == CURRENT_NODE{
                    if let checkerForHub = i["locname"] as? String{
                        if checkerForHub.contains("Hub "){
                            let n = i["node"] as! Int
                            if n != shortestPath.first!{
                                speakThis(sentence: "Re-Routing")
                                shortestPath = pathFinder(current: n, destination: shortestPath.last!)
                                break
                            }
                        }
                    }
                }
            }
            print(shortestPath)
            if userAngle != -1{
                atBeaconInstr = instructions(path: shortestPath, angle: userAngle)
                indoorKeyIgnition()
            }
            else{
                print("User's Angle is still -1")
            }
            pathFound = false
        }
        
        //            print("Beacon: " + String(describing: beacon) + " " + String(distance))
        if distance > Double(userDefinedRssi) && explorationFlag && !indoorWayFindingFlag{
            // CURRENT_NODE is the beacon_id of the beacon
            explorationMode(currentNode: CURRENT_NODE)
        }
        if distance > Double(userDefinedRssi) && indoorWayFindingFlag{
            if !self.checkForReRoute(currNode: self.CURRENT_NODE){
                self.indoorWayFinding(beaconRSSI: Float(distance))
                self.stopRepeatsFlag = true
            }
        }
        else{
            if indoorWayFindingFlag && stopRepeatsFlag && !isOnRoute{
                if(stopBtn.isHidden){
                    stopBtn.isHidden = false
                    stopLabel.isHidden = false
                }
                speakThis(sentence: "Please move closer to a beacon for directions.")
                stopRepeatsFlag = false
            }
        }
    }
    
    //    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
    //        var filteredBeacons : [CLBeacon] = []
    //        for i in beacons{
    //            if i.rssi != 0{
    //                filteredBeacons.append(i)
    //            }
    //        }
    
    //        if beacons.count > 0{
    //            for a in beacons{
    //                if a.rssi < 0{
    //                    print("==> Beacon: " + String(describing: a.minor) + " RSSI: " + String(a.rssi))
    //                }
    //            }
    //        }
    
    //        if let beacon = filteredBeacons.first{
    //            updateBeaconReading(distance: beacon.proximity, beacon: beacon)
    //        }
    //        else{
    //            updateBeaconReading(distance: .unknown, beacon: nil)
    //        }
    //    }
    
    func presentAlert(alert : UIAlertController){       // Funtion to help with alerts to the user
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapStop(_ sender: Any) {          // For the X icon. When tapped exit navigation mode
//        speakThis(sentence: "Stoping routing")

        indoorWayFindingFlag = false
        if UIDevice.current.userInterfaceIdiom == .phone{
            hapticVibration(atDestination: true)
        }
        //explorationFlag = true
        speechFlag = true
        recursionFlag = false
        stopBtn.isHidden = true
        stopLabel.isHidden = true
        //speakThis(sentence: "Routing stopped. Switching to exploration mode.")
        
        // trial trial
        // after a 3.5 second delay, replaces previous text with the below text
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.speakThis(sentence: "Navigation cancelled. Switching to Exploration mode.")
            self.instrLabel.text = "Navigation cancelled. Switching to Exploration mode."

        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.5) {
            self.explorationFlag = true
        }
    }
    
    
    
//    override func didReceiveMemoryWarning() {
//           super.didReceiveMemoryWarning()
//           // Dispose of any resources that can be recreated.
//       }

    
    @IBAction func sendEmail(_ sender: Any) {
           
        //speakThis(sentence: "Feedback")
           
//           let mailComposeViewController = configureMailController()
//           if MFMailComposeViewController.canSendMail() {
//               self.present(mailComposeViewController, animated: true, completion: nil)
//           } else {
//               showMailError()
//           }
           
           
        let alertController = UIAlertController(title: "\n", message: "After clicking the 'Submit' button, you will be taken to a new window where you can share any additional comments or feedback with our development team through email.", preferredStyle: .alert)

        // Create the rating control
        let ratingControl = RatingControl(frame: CGRect(x: 0, y: 0, width: 230, height: 50))
        alertController.view.addSubview(ratingControl)

        // Add the "Cancel" action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Add the "Submit" action
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
        // User clicked the "Submit" button, show the email composer
        self.showEmailComposer(withRating: ratingControl.rating)}))

        // Show the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    
    func showEmailComposer(withRating rating: Int) {
        // Create and configure the email composer
        let composer = MFMailComposeViewController()
        
        // Extremely important to set the mailComposeDelegate property, NOT the delegate property
        composer.mailComposeDelegate = self
        
        composer.setToRecipients(["wsuaccesslab@gmail.com"])
        composer.setSubject("App Rating")
        let CURRENT_NODE_key = userDefaults.string(forKey: "CURRENT_NODE_key")
        
        let groupID_key = userDefaults.string(forKey: "groupID_key")

        if(CURRENT_NODE_key! == "-1" && groupID_key! == "-1"){
            
            composer.setMessageBody("Hello CityGuide team, \n\nI gave your app \(rating) stars. \n\nCurrently, not in proximity to any beacon. \n\nThe dev team welcomes any further comments or feedback you would like to share.\n\n", isHTML: false)
            
            // Show the email composer
            self.present(composer, animated: true, completion: nil)
            
        }
        else{
            
            composer.setMessageBody("Hello CityGuide team, \n\n I gave your app \(rating) stars. \n\nI am currently standing near beacon \(CURRENT_NODE_key!) and its groupID is \(groupID_key!). \n\nThe dev team welcomes any further comments or feedback you would like to share. In your message, please furnish details regarding your initial location prior to activating the navigation mode within the application.\n\n", isHTML: false)
            
            // Show the email composer
            self.present(composer, animated: true, completion: nil)
        }
    }
    
    
    // This is the only callback from the Mail composer to notify the app that the user has carried out certain action
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    @IBAction func didTapSettingsButton() {      // button for settings
        let tvc = Settings_Table_Controller()
        tvc.items = [
            "User Category",
            "Route Preview",
            "Distance Unit",
            "Referece Distance Unit",
            "Orientation Preference" ,
            "Monitoring" ,
            "Step Size (ft)",
            "Weighted Moving Average",
            "Set Threshold" ,
            "Timer (Seconds)",
            "Searching Radius (Meters)" ,
            "GPS Accuracy"
        ]
        tvc.title = "Settings"
        
        navigationController?.pushViewController(tvc, animated: true)
        
    }
    */
    
    @IBAction func searchTapped(_ sender: Any) {        // 'Text Search' button method
        //speakThis(sentence: "Search for destination")

        for i in dArray{
            if i["beacon_id"] as! Int == CURRENT_NODE{
                if let checkerForHub = i["locname"] as? String{
                    if checkerForHub.contains("Hub "){
                        let n = i["node"] as! Int
                        srVC.setCurrentNode(node: n)
                        break
                    }
                }
            }
        }
        navigationController?.pushViewController(srVC, animated: true)
    }
    
    @IBAction func exitButtonTapped(_ sender: Any) {        // 'Exits' button method
        //speakThis(sentence: "Check for emergency exits")

        for i in dArray{
            if i["beacon_id"] as! Int == CURRENT_NODE{
                if let checkerForHub = i["locname"] as? String{
                    if checkerForHub.contains("Hub "){
                        let n = i["node"] as! Int
                        erVC.setCurrentNode(node: n)
                        break
                    }
                }
            }
        }
        navigationController?.pushViewController(erVC, animated: true)
    }
    
    @IBAction func restroomsButtonTapped(_ sender: Any) {   // 'Restrooms' button method
        //speakThis(sentence: "Check for restrooms")

        for i in dArray{
            if i["beacon_id"] as! Int == CURRENT_NODE{
                if let checkerForHub = i["locname"] as? String{
                    if checkerForHub.contains("Hub "){
                        let n = i["node"] as! Int
                        rrVC.setCurrentNode(node: n)
                        break
                    }
                }
            }
        }
        navigationController?.pushViewController(rrVC, animated: true)
    }
    
    
    // EXPLORATION MODE
    // currentNode takes the beacon_id of the current beacon
    func explorationMode(currentNode : Int){
        
        // TURN ON accessibility to these buttons when not in navigation mode
        self.feedbackBtn.isAccessibilityElement = true
        self.textSearchBtn.isAccessibilityElement = true
        self.recButton.isAccessibilityElement = true
        self.exitsBtn.isAccessibilityElement = true
        self.restroomsBtn.isAccessibilityElement = true
        
        
        
        if destinations.isEmpty{
            return
        }
        isOnRoute = false
        var POI : [Int] = []
        var locnames : [String] = []
        var curNode = -1
        for i in dArray{
            if i["beacon_id"] as! Int == CURRENT_NODE{
                if var checkerForHub = i["locname"] as? String{
                    if !checkerForHub.contains("Hub "){               // when locname does not have the word "Hub"
                        
                        
                        // trial trial...to remove the app from saying "W H " or building name with every PoI
                        checkerForHub.removeFirst(4)
                        
                        
                        let n = i["node"] as! Int
                        if !POI.contains(n){
                            POI.append(n)
                            locnames.append(checkerForHub)
                        }
                    }
                    else{                                          // when locname has the word "Hub"
                        let n = i["node"] as! Int
                        curNode = n
                    }
                }
            }
        }
        if !POI.isEmpty && userAngle != -1 && curNode != -1{
            poiAtCurrentNode = generatePOIDirections(POI: POI, angle: userAngle, currentNode: curNode)
            speechFlag = true
        }
        
        if speechFlag && !recursionFlag && !voiceSearchFlag && !muteFlag{
            
            //let numPOI = POI.count
            
            //to stop narration of PoIs immediately and start narration of new PoIs when moving swiftly from one beacon to the next
            if(narator.isSpeaking){
                narator.stopSpeaking(at: .immediate)
            }
            // if numPOI > 1{
            //     speakThis(sentence: "You are near " + String(numPOI) + " points of interest")
            // }
            
            // POI is the array of PoI node numbers associated with each beacon...so for beacon 1, the POI will be [1, 2] which are nodes 1 & 2
            for j in POI{
                // print(POI)
                // print(locnames)
                // print(poiAtCurrentNode)
                let index = POI.firstIndex(of: j)
                let sentence = locnames[index!] + " is " + poiAtCurrentNode[j]!     // narration of PoIs associated with a beacon
                speakThis(sentence: sentence)
                
                
                
                
                
                /*
                // VoiceOver ACTIVE
                if UIAccessibility.isVoiceOverRunning{
                    self.floorPlan.accessibilityLabel = "\(sentence)"
                }
                
                // VoiceOver NOT ACTIVE
                else{
                    speakThis(sentence: sentence)
                }
                */
                
                
                
                
                
                
                // trial trial
                // displays the nearby POIs as text
                DispatchQueue.main.async{
                    //self.instrLabel.text = "\(locnames[index!] + " is " + self.poiAtCurrentNode[j]!)"
                    self.instrLabel.textColor = UIColor.white
                    var allPOItext = (self.instrLabel.text ?? "") + "\n" + (self.poiAtCurrentNode[j]! + ": " + locnames[index!])
                    
                    // to remove "Exploration mode active" line on top of PoI info in label
                    if allPOItext.contains("Exploration mode active"){
                        //allPOItext = allPOItext.filter{$0 != "Exploration mode active"}
                        allPOItext.removeFirst(23)
                    }
                    
                    // to remove "Navigation cancelled. Switching to Exploration mode." line on top of PoI info in label
                    if allPOItext.contains("Navigation cancelled. Switching to Exploration mode."){
                        //allPOItext = allPOItext.filter{$0 != "Exploration mode active"}
                        allPOItext.removeFirst(52)
                    }
                    
                    // to remove duplicate lines of PoI info from showing up in label
                    let components = allPOItext.components(separatedBy: .newlines)
                    let depDup = components.reduce([]){
                        $0.contains($1) ? $0 : $0 + [$1]
                    }.joined(separator: "\n")
                    
                    self.instrLabel.text = depDup
                }
                
                // after a 5 second delay, replaces above text with the below text
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                    //self.instrLabel.textColor = UIColor.systemYellow
                    self.instrLabel.text = "Exploration mode active"
                    //self.instrLabel.text = nil
                }
                                
            }
            
            currentlyAt = CURRENT_NODE
            recursionFlag = true
            speechFlag = false
        }
        if currentlyAt != CURRENT_NODE{
            recursionFlag = false
            speechFlag = true
        }
    }
    
    // NAVIGATION MODE???
    func indoorWayFinding(beaconRSSI : Float){
        
        // TURN ON/OFF accessibility to these buttons when in navigation mode
        self.feedbackBtn.isAccessibilityElement = false
        self.textSearchBtn.isAccessibilityElement = false
        self.recButton.isAccessibilityElement = false
        self.exitsBtn.isAccessibilityElement = false
        self.restroomsBtn.isAccessibilityElement = false
        
        
        
        // Define the SF Symbols for each direction instruction

        
        //let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let config = UIImage.SymbolConfiguration(pointSize: 35)
        
        let upArrow = NSTextAttachment()
        upArrow.image = UIImage(systemName: "arrow.up", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let upArrowImageString = NSMutableAttributedString(attachment: upArrow)
        
        let slightRightArrow = NSTextAttachment()
        slightRightArrow.image = UIImage(systemName: "arrow.up.right", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let slightRightArrowImageString = NSMutableAttributedString(attachment: slightRightArrow)
        
        let slightLeftArrow = NSTextAttachment()
        slightLeftArrow.image = UIImage(systemName: "arrow.up.left", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let slightLeftArrowImageString = NSMutableAttributedString(attachment: slightLeftArrow)
        
        let rightArrow = NSTextAttachment()
        rightArrow.image = UIImage(systemName: "arrow.turn.up.right", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let rightArrowImageString = NSMutableAttributedString(attachment: rightArrow)
        
        let leftArrow = NSTextAttachment()
        leftArrow.image = UIImage(systemName: "arrow.turn.up.left", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let leftArrowImageString = NSMutableAttributedString(attachment: leftArrow)
        
        let turnAroundArrow = NSTextAttachment()
        turnAroundArrow.image = UIImage(systemName: "arrow.uturn.down", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let turnAroundArrowImageString = NSMutableAttributedString(attachment: turnAroundArrow)
        
        let clock4Arrow = NSTextAttachment()
        clock4Arrow.image = UIImage(systemName: "arrow.down.right", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let clock4ArrowImageString = NSMutableAttributedString(attachment: clock4Arrow)
        
        let clock7Arrow = NSTextAttachment()
        clock7Arrow.image = UIImage(systemName: "arrow.down.left", withConfiguration: config)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let clock7ArrowImageString = NSMutableAttributedString(attachment: clock7Arrow)
        
        
        
        
        
        
        
        
        
        DispatchQueue.main.async {
            if self.stopBtn.isHidden{
                self.stopBtn.isHidden = false
                self.stopLabel.isHidden = false
            }
        }
        var exitToExplore = ""
        if speechFlag && !recursionFlag{
            if UIDevice.current.userInterfaceIdiom == .phone{
                hapticVibration()
            }
            for i in dArray{
                if i["beacon_id"] as! Int == CURRENT_NODE{
                    if let checkerForHub = i["locname"] as? String{
                        if checkerForHub.contains("Hub "){
                            let n = i["node"] as! Int
                            let validRSSI = i["threshold"] as! Float
                            if beaconRSSI < validRSSI{     // Check if within RSSI range set by server entry
                                if atBeaconInstr[n]!.contains("destination."){
                                    indoorWayFindingFlag = false
                                    print("Near Destination")

                                    if UIDevice.current.userInterfaceIdiom == .phone{
                                        hapticVibration(atDestination: true)
                                    }
                                    explorationFlag = true
                                    speechFlag = true
                                    recursionFlag = false
                                    exitToExplore = "Switching back to Exploration Mode. Please leave a feedback."
                                    

                                    // create an instance of UIAlertController
//                                    let alert = UIAlertController(title: "Confirmation", message: "do you want to give a feedback?", preferredStyle: .alert)
//
//                                    // create actions for the Yes and No buttons
//                                    let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
//                                        // handle "Yes" action here
//                                    }
//
//                                    let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
//                                        // handle "No" action here
//                                    }
//
//                                    // add the actions to the alert
//                                    alert.addAction(yesAction)
//                                    alert.addAction(noAction)
//
//                                    // present the alert
//                                    present(alert, animated: true, completion: nil)
                                    
                                    
                                    
                                    
                                    DispatchQueue.main.async {
                                        if !self.stopBtn.isHidden{
                                            self.stopBtn.isHidden = true
                                            self.stopLabel.isHidden = true
                                        }
                                    }

                                }
                                if(narator.isSpeaking && indoorWayFindingFlag && !muteFlag){
                                    if shortestPath.contains(n){
                                        if n != shortestPath.first{
                                            while(n != shortestPath.first){
                                                shortestPath.remove(at: 0)
                                            }
                                        }
                                    }
                                    else{
                                        return
                                    }
                                    
                                    speakThis(sentence: atBeaconInstr[n]!)
                                    
                                    /*
                                    // VoiceOver ACTIVE
                                    if UIAccessibility.isVoiceOverRunning{
                                        self.floorPlan.accessibilityLabel = "\(self.atBeaconInstr[n]!)"
                                    }
                                    
                                    // VoiceOver NOT ACTIVE
                                    else{
                                        speakThis(sentence: atBeaconInstr[n]!)
                                    }
                                    */
                                    
                                    // trial trial...give turn-by-turn instructions as text
                                    let navText = "\(self.atBeaconInstr[n]!)"
                                    
                                    if navText.contains("for"){
                                        // Split the input string by 'for'
                                        let firstSplit = navText.components(separatedBy: "for")
                                        if firstSplit[0].contains("and"){
                                            let secondSplit = firstSplit[0].components(separatedBy: "and")
                                            
                                            // "Turn SLIGHT RIGHT and go STRAIGHT for "
                                            if secondSplit[0].contains("slight right"){
                                                let firstPart = NSMutableAttributedString(string: "Turn slight right ")
                                                firstPart.append(slightRightArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(thirdPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn SLIGHT LEFT and go STRAIGHT for "
                                            if secondSplit[0].contains("slight left"){
                                                let firstPart = NSMutableAttributedString(string: "Turn slight left ")
                                                firstPart.append(slightLeftArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(thirdPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Take a SHARP RIGHT and go STRAIGHT for "
                                            if secondSplit[0].contains("sharp right"){
                                                let firstPart = NSMutableAttributedString(string: "Take a sharp right ")
                                                firstPart.append(rightArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(thirdPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Take a SHARP LEFT and go STRAIGHT for "
                                            if secondSplit[0].contains("sharp left"){
                                                let firstPart = NSMutableAttributedString(string: "Take a sharp left ")
                                                firstPart.append(leftArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(thirdPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn AROUND and go STRAIGHT for "
                                            if secondSplit[0].contains("around"){
                                                let firstPart = NSMutableAttributedString(string: "Turn around ")
                                                firstPart.append(turnAroundArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(thirdPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn 4 O'CLOCK and go STRAIGHT for "
                                            if secondSplit[0].contains("4 o'clock"){
                                                let firstPart = NSMutableAttributedString(string: "Turn 4 o'clock ")
                                                firstPart.append(clock4ArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(thirdPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn 7 O'CLOCK and go STRAIGHT for "
                                            if secondSplit[0].contains("7 o'clock"){
                                                let firstPart = NSMutableAttributedString(string: "Turn 7 o'clock ")
                                                firstPart.append(clock7ArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(thirdPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            
                                        }
                                        else{
                                            //"Go STRAIGHT for "
                                            let firstPart = NSMutableAttributedString(string: "Go straight ")
                                            firstPart.append(upArrowImageString)
                                            
                                            let secondPart = NSMutableAttributedString(string: firstSplit[1])
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    else{
                                        
                                        // "Go STRAIGHT"
                                        if navText.contains("Go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Go straight ")
                                            firstPart.append(upArrowImageString)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                        // "Turn SLIGHT RIGHT and go STRAIGHT"
                                        if navText.contains("Turn slight right and go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Turn slight right ")
                                            firstPart.append(slightRightArrowImageString)
                                            let secondPart = NSMutableAttributedString(string: ", go straight ")
                                            secondPart.append(upArrowImageString)
                                            
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                        // "Turn SLIGHT LEFT and go STRAIGHT"
                                        if navText.contains("Turn slight left and go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Turn slight left ")
                                            firstPart.append(slightLeftArrowImageString)
                                            let secondPart = NSMutableAttributedString(string: ", go straight ")
                                            secondPart.append(upArrowImageString)
                                            
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                        // "Take a SHARP RIGHT and go STRAIGHT"
                                        if navText.contains("Take a sharp right and go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Take a sharp right ")
                                            firstPart.append(rightArrowImageString)
                                            let secondPart = NSMutableAttributedString(string: ", go straight ")
                                            secondPart.append(upArrowImageString)
                                            
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                        // "Take a SHARP LEFT and go STRAIGHT"
                                        if navText.contains("Take a sharp left and go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Take a sharp left ")
                                            firstPart.append(leftArrowImageString)
                                            let secondPart = NSMutableAttributedString(string: ", go straight ")
                                            secondPart.append(upArrowImageString)
                                            
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                        // "Turn AROUND and go STRAIGHT"
                                        if navText.contains("Turn around and go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Turn around ")
                                            firstPart.append(turnAroundArrowImageString)
                                            let secondPart = NSMutableAttributedString(string: ", go straight ")
                                            secondPart.append(upArrowImageString)
                                            
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                        // "Turn 4 O'CLOCK and go STRAIGHT"
                                        if navText.contains("Turn 4 o'clock and go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Turn 4 o'clock ")
                                            firstPart.append(clock4ArrowImageString)
                                            let secondPart = NSMutableAttributedString(string: ", go straight ")
                                            secondPart.append(upArrowImageString)
                                            
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }
                                        
                                        // "Turn 7 O'CLOCK and go STRAIGHT"
                                        if navText.contains("Turn 7 o'clock and go straight"){
                                            let firstPart = NSMutableAttributedString(string: "Turn 7 o'clock ")
                                            firstPart.append(clock7ArrowImageString)
                                            let secondPart = NSMutableAttributedString(string: ", go straight ")
                                            secondPart.append(upArrowImageString)
                                            
                                            firstPart.append(secondPart)
                                            
                                            DispatchQueue.main.async {
                                                self.instrLabel.attributedText = firstPart
                                            }
                                        }

                                        
                                        /*
                                         DispatchQueue.main.async {
                                         
                                         self.instrLabel.attributedText = firstPart
                                         }
                                         */
                                        
                                    }
                                }
                                else{
                                    if !muteFlag{
                                        speakThis(sentence: atBeaconInstr[n]!)
                                        
                                        /*
                                        // VoiceOver ACTIVE
                                        if UIAccessibility.isVoiceOverRunning{
                                            self.floorPlan.accessibilityLabel = "\(self.atBeaconInstr[n]!)"
                                        }
                                        
                                        // VoiceOver NOT ACTIVE
                                        else{
                                            speakThis(sentence: atBeaconInstr[n]!)
                                        }
                                        */
                                        
                                        // trial trial...give turn-by-turn instructions as text
                                        
                                        let navText = "\(self.atBeaconInstr[n]!)"
                                        
                                        if navText.contains("for"){
                                            // Split the input string by 'for'
                                            let firstSplit = navText.components(separatedBy: "for")
                                            if firstSplit[0].contains("and"){
                                                let secondSplit = firstSplit[0].components(separatedBy: "and")
                                                
                                                // "Turn SLIGHT RIGHT and go STRAIGHT for "
                                                if secondSplit[0].contains("slight right"){
                                                    let firstPart = NSMutableAttributedString(string: "Turn slight right ")
                                                    firstPart.append(slightRightArrowImageString)
                                                    let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                    secondPart.append(upArrowImageString)
                                                    
                                                    firstPart.append(secondPart)
                                                    
                                                    let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                    firstPart.append(thirdPart)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.instrLabel.attributedText = firstPart
                                                    }
                                                }
                                                
                                                // "Turn SLIGHT LEFT and go STRAIGHT for "
                                                if secondSplit[0].contains("slight left"){
                                                    let firstPart = NSMutableAttributedString(string: "Turn slight left ")
                                                    firstPart.append(slightLeftArrowImageString)
                                                    let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                    secondPart.append(upArrowImageString)
                                                    
                                                    firstPart.append(secondPart)
                                                    
                                                    let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                    firstPart.append(thirdPart)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.instrLabel.attributedText = firstPart
                                                    }
                                                }
                                                
                                                // "Take a SHARP RIGHT and go STRAIGHT for "
                                                if secondSplit[0].contains("sharp right"){
                                                    let firstPart = NSMutableAttributedString(string: "Take a sharp right ")
                                                    firstPart.append(rightArrowImageString)
                                                    let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                    secondPart.append(upArrowImageString)
                                                    
                                                    firstPart.append(secondPart)
                                                    
                                                    let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                    firstPart.append(thirdPart)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.instrLabel.attributedText = firstPart
                                                    }
                                                }
                                                
                                                // "Take a SHARP LEFT and go STRAIGHT for "
                                                if secondSplit[0].contains("sharp left"){
                                                    let firstPart = NSMutableAttributedString(string: "Take a sharp left ")
                                                    firstPart.append(leftArrowImageString)
                                                    let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                    secondPart.append(upArrowImageString)
                                                    
                                                    firstPart.append(secondPart)
                                                    
                                                    let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                    firstPart.append(thirdPart)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.instrLabel.attributedText = firstPart
                                                    }
                                                }
                                                
                                                // "Turn AROUND and go STRAIGHT for "
                                                if secondSplit[0].contains("around"){
                                                    let firstPart = NSMutableAttributedString(string: "Turn around ")
                                                    firstPart.append(turnAroundArrowImageString)
                                                    let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                    secondPart.append(upArrowImageString)
                                                    
                                                    firstPart.append(secondPart)
                                                    
                                                    let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                    firstPart.append(thirdPart)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.instrLabel.attributedText = firstPart
                                                    }
                                                }
                                                
                                                // "Turn 4 O'CLOCK and go STRAIGHT for "
                                                if secondSplit[0].contains("4 o'clock"){
                                                    let firstPart = NSMutableAttributedString(string: "Turn 4 o'clock ")
                                                    firstPart.append(clock4ArrowImageString)
                                                    let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                    secondPart.append(upArrowImageString)
                                                    
                                                    firstPart.append(secondPart)
                                                    
                                                    let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                    firstPart.append(thirdPart)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.instrLabel.attributedText = firstPart
                                                    }
                                                }
                                                
                                                // "Turn 7 O'CLOCK and go STRAIGHT for "
                                                if secondSplit[0].contains("7 o'clock"){
                                                    let firstPart = NSMutableAttributedString(string: "Turn 7 o'clock ")
                                                    firstPart.append(clock7ArrowImageString)
                                                    let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                    secondPart.append(upArrowImageString)
                                                    
                                                    firstPart.append(secondPart)
                                                    
                                                    let thirdPart = NSMutableAttributedString(string: firstSplit[1])
                                                    firstPart.append(thirdPart)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.instrLabel.attributedText = firstPart
                                                    }
                                                }
                                                
                                                
                                            }
                                            else{
                                                //"Go STRAIGHT for "
                                                let firstPart = NSMutableAttributedString(string: "Go straight ")
                                                firstPart.append(upArrowImageString)
                                                
                                                let secondPart = NSMutableAttributedString(string: firstSplit[1])
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        else{
                                            
                                            // "Go STRAIGHT"
                                            if navText.contains("Go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Go straight ")
                                                firstPart.append(upArrowImageString)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn SLIGHT RIGHT and go STRAIGHT"
                                            if navText.contains("Turn slight right and go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Turn slight right ")
                                                firstPart.append(slightRightArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn SLIGHT LEFT and go STRAIGHT"
                                            if navText.contains("Turn slight left and go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Turn slight left ")
                                                firstPart.append(slightLeftArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Take a SHARP RIGHT and go STRAIGHT"
                                            if navText.contains("Take a sharp right and go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Take a sharp right ")
                                                firstPart.append(rightArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Take a SHARP LEFT and go STRAIGHT"
                                            if navText.contains("Take a sharp left and go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Take a sharp left ")
                                                firstPart.append(leftArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn AROUND and go STRAIGHT"
                                            if navText.contains("Turn around and go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Turn around ")
                                                firstPart.append(turnAroundArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn 4 O'CLOCK and go STRAIGHT"
                                            if navText.contains("Turn 4 o'clock and go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Turn 4 o'clock ")
                                                firstPart.append(clock4ArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                            // "Turn 7 O'CLOCK and go STRAIGHT"
                                            if navText.contains("Turn 7 o'clock and go straight"){
                                                let firstPart = NSMutableAttributedString(string: "Turn 7 o'clock ")
                                                firstPart.append(clock7ArrowImageString)
                                                let secondPart = NSMutableAttributedString(string: ", go straight ")
                                                secondPart.append(upArrowImageString)
                                                
                                                firstPart.append(secondPart)
                                                
                                                DispatchQueue.main.async {
                                                    self.instrLabel.attributedText = firstPart
                                                }
                                            }
                                            
                                        }

                                        /*
                                        DispatchQueue.main.async {
                                            self.instrLabel.text = "\(self.atBeaconInstr[n]!)"
                                        }
                                        */
                                        
                                    }
                                }
                                if exitToExplore != "" && !muteFlag{
                                    speakThis(sentence: exitToExplore)
                                    
                                    
                                    // after a 6 second delay, replaces previous text with the below text
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
                                        self.instrLabel.text = "Switching to Exploration mode"
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
                                        self.instrLabel.text = "Exploration mode active"
                                    }
                                    

                                    
                                    indoorWayFindingFlag = false
                                    recursionFlag = true
                                    explorationFlag = true
                                }
                                isOnRoute = true
                            }
                        }
                    }
                }
            }
            currentlyAt = CURRENT_NODE
            recursionFlag = true
        }
        if currentlyAt != CURRENT_NODE{
            recursionFlag = false
        }
    }
    
    func checkForReRoute(currNode : Int) -> Bool{
        for i in dArray{
            if i["beacon_id"] as! Int == currNode{
                if let checkerForHub = i["locname"] as? String{
                    if checkerForHub.contains("Hub "){
                        let n = i["node"] as! Int
                        if !shortestPath.contains(n){
                            speakThis(sentence: "Rerouting")
                            if UIDevice.current.userInterfaceIdiom == .phone{
                                hapticVibration()
                            }
                            shortestPath = pathFinder(current: n, destination: shortestPath.last!)
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func singleFire(check : Int?){          // Listen to the user's verbal responses, and implement methods based on reponses.
        let audioSession = AVAudioSession.sharedInstance()
        do
        {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setMode(AVAudioSession.Mode.default)
            //try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
        catch
        {
            print("audioSession properties weren't set because of an error.")
        }
        
        voiceSearchFlag = true
        group.enter()
        if check == 1{
            DispatchQueue.main.async(group: group){
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    AudioServicesPlaySystemSound(1113)
                    if UIDevice.current.userInterfaceIdiom == .phone{
                        self.hapticVibration()
                    }
                    self.speechRecognizer.reset()
                    self.speechRecognizer.transcribe()
                    print("Transcription started...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4, qos: .default) {
                        self.speechRecognizer.stopTranscribing()
                        print("Transcription has stopped...")
                        print(self.speechRecognizer.transcript)
                        if(self.speechRecognizer.transcript.lowercased() == "yes" || self.speechRecognizer.transcript.lowercased() == "yup" || self.speechRecognizer.transcript.lowercased() == "confirmed"){
                            self.userResponse = true
                        }
                        self.group.leave()
                    }
                }
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speakThis(sentence: "Please say your destination after the indication.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    AudioServicesPlaySystemSound(1113)
                    if UIDevice.current.userInterfaceIdiom == .phone{
                        self.hapticVibration()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                        self.speechRecognizer.reset()
                        self.speechRecognizer.transcribe()
                        print("Transcription started...")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, qos: .default) {
                            self.speechRecognizer.stopTranscribing()
                            print("Transcription has stopped...")
                            print(self.speechRecognizer.transcript)
                            self.checkForDistination(userDes: self.speechRecognizer.transcript)
                            self.group.leave()
                        }
                    }
                }
            }
        }
    }
    
    func checkForDistination(userDes : String){     // Checks if user specified destination is available in the pool
        var dest = ""
        var range = 0
        var similarToDest = ""
        var userDestination = userDes
        
        //wh308 -> w h 308
        let decimalChars = CharacterSet.decimalDigits
        let decimalRange = userDestination.rangeOfCharacter(from: decimalChars)
        var temp = ""
        if decimalRange != nil{
            for i in Array(userDestination.lowercased()){
                if i.isLetter{
                    temp.append(i)
                    temp.append(" ")
                }
                else{
                    temp.append(i)
                }
            }
            userDestination = temp
        }
        
        for k in destinations{
            var testRange = 0
            if k.lowercased() == userDestination.lowercased(){
                dest = k
                break
            }
            else{
                let words = userDestination.lowercased()
                let destWords = k.lowercased()
                for l in words.components(separatedBy: " "){
                    if destWords.contains(l){
                        testRange+=2
                        if destWords.starts(with: l){
                            testRange*=2
                        }
                    }
                    //                    else{
                    //                        for o in destWords.components(separatedBy: " "){
                    //                            if l != "" && o != ""{
                    //                                let check = levenshtein(aStr: l, bStr: o)
                    //                                if(check < 3){
                    //                                    testRange += 1
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                }
                if range < testRange{
                    range = testRange
                    similarToDest = k
                    testRange = 0
                }
            }
        }
        
        if similarToDest != ""{
            speakThis(sentence: "Did you mean " + similarToDest + "? Please confirm or say no after the indication.")
            singleFire(check: 1)
            group.notify(queue: .main){
                if self.userResponse{
                    dest = similarToDest
                    self.userResponse = false
                }
                else{
                    self.speakThis(sentence: "Search cancelled.")
                    self.voiceSearchFlag = false
                    return
                }
                var currNode = -1
                for i in dArray{
                    if i["beacon_id"] as! Int == self.CURRENT_NODE{
                        if let checkerForHub = i["locname"] as? String{
                            if checkerForHub.contains("Hub "){
                                currNode = i["node"] as! Int
                                break
                            }
                        }
                    }
                }
                for i in dArray{
                    if i["locname"] as? String == dest && currNode != -1{
                        let desNode = Int(truncating: i["node"] as! NSNumber)
                        self.indoorKeyIgnition()
                        self.voiceSearchFlag = false
                        shortestPath = pathFinder(current: currNode, destination: desNode)
                        break
                    }
                }
            }
        }
        else if dest != ""{
            var currNode = -1
            for i in dArray{
                if i["beacon_id"] as! Int == self.CURRENT_NODE{
                    if let checkerForHub = i["locname"] as? String{
                        if checkerForHub.contains("Hub "){
                            currNode = i["node"] as! Int
                            break
                        }
                    }
                }
            }
            for i in dArray{
                if i["locname"] as? String == dest && currNode != -1{
                    let desNode = Int(truncating: i["node"] as! NSNumber)
                    self.indoorKeyIgnition()
                    self.voiceSearchFlag = false
                    shortestPath = pathFinder(current: currNode, destination: desNode)
                    break
                }
            }
        }
        else{
            self.speakThis(sentence: "Sorry, no destination was found.")
            self.voiceSearchFlag = false
            return
        }
    }
    
    func indoorKeyIgnition(){           // Sets flags just for navigation mode to work properly
        speechFlag = true
        recursionFlag = false
        indoorWayFindingFlag = true
        explorationFlag = false
    }
    
    func hapticVibration(atDestination : Bool? = false){
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
        let parameter = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, end], relativeTime: 0)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 0.5)
        
        if atDestination! == true{
            usleep(500000) //0.5 seconds
        }
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [parameter])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func speakThis(sentence : String){
        let audioSession = AVAudioSession.sharedInstance()
        do
        {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setMode(AVAudioSession.Mode.default)
            //try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
        catch
        {
            print("audioSession properties weren't set because of an error.")
        }
        
        //
        var user = 1
        let userProfile = UserDefaults.standard.value(forKey: "checkmarks") as? [String:Int]
        if userProfile == nil{
            user = 0
        }
        else if !userProfile!.isEmpty{
            user = userProfile!["User Category"]!
        }
        
        let utterance = AVSpeechUtterance(string: sentence)
        if user == 0{
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.7
        }
        else{
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.6
        }
        
        if(narator.isSpeaking && explorationFlag && voiceSearchFlag){
            narator.stopSpeaking(at: .immediate)
        }
        
        if !muteFlag{
            narator.speak(utterance)
        }
        else{
            narator.stopSpeaking(at: .immediate)
        }
    }
    
    @IBAction func switchMuteTo(_ sender: Any) {
        if(!muteFlag){
            speakThis(sentence: "Mute ON")

            self.naratorMute.setImage(UIImage(systemName: "volume.slash.fill"), for: .normal)
            if narator.isSpeaking{
                narator.stopSpeaking(at: .immediate)
            }
            muteFlag = true
            self.naratorMute.accessibilityLabel = "Unmute button"
        }
        else{
            speakThis(sentence: "Mute OFF")

            self.naratorMute.setImage(UIImage(systemName: "volume.fill"), for: .normal)
            if narator.isSpeaking{
                narator.stopSpeaking(at: .immediate)
            }
            muteFlag = false
            self.naratorMute.accessibilityLabel = "Mute button"
        }
    }
    @objc func doubleTapped() {
        // do something here
        print("*********** Speak Again Command Detected ***********")
        if explorationFlag && !muteFlag{
            speechFlag = true
            recursionFlag = false
        }
        if indoorWayFindingFlag && !muteFlag{
            if !stopRepeatsFlag{
                speakThis(sentence: "Please move closer to a recognizable beacon")
            }
            else{
                for i in dArray{
                    if i["beacon_id"] as! Int == CURRENT_NODE{
                        if let checkerForHub = i["locname"] as? String{
                            if checkerForHub.contains("Hub "){
                                let n = i["node"] as! Int
                                speakThis(sentence: atBeaconInstr[n]!)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}


//extension HomeVC: MFMailComposeViewController{
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//
//           if let _ = error {
//               //Show error alert
//               controller.dismiss(animated: true)
//               return
//           }
//
//           switch result {
//           case .cancelled:
//               print("Cancelled")
//           case .failed:
//               print("Failed to send")
//           case .saved:
//               print("Saved")
//           case .sent:
//               print("Email Sent")
//           @unknown default:
//               break
//           }
//
//           controller.dismiss(animated: true)
//       }
//}



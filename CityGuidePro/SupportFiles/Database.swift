//
//  Database.swift
//  CityGuide
//
//  Updated by AJ
//

import Foundation
import UIKit
import MapKit

var beaconData : [String:Any] = [  // A default beacon information template
    "beacon_id" : -1,
    "group_id" : -1,
    "node" : -1,
    "numsens" : -50,
    "threshold" : -70,
    "direction" : -2,
    "locname" : "",
    "other" : "",
    "_level" : -3,
    "edist" : "-10",
    "beast" : "-10",
    "bnorth" : "-10",
    "bneast" : "-10",
    "bnwest" : "-10",
    "bseast" : "-10",
    "bsouth" : "-10",
    "bswest" : "-10",
    "bwest" : "-10",
    "ndist" : "-10",
    "neastdist" : "-10",
    "nwestdist" : "-10",
    "sdist" : "-10",
    "seastdist" : "-10",
    "swestdist" : "-10",
    "wdist" : "-10",
]
var dArray : [[String:Any]] = []  // The array containting values of a cluster of beacons
var destinations : [String] = []
var listOfBeacon : [Int] = []
var image : UIImage? = nil

func postToDB(typeOfAction: String, beaconID: Int, auth: String, floorNum: Int?, vc : UIViewController){        // Main function
    switch typeOfAction{
        case "beacons":
            // trial trial
            //let url = URL(string: "http://wh-308-3922mm.dyn.wichita.edu:5000/data")
            let url = URL(string: "http://34.16.171.175:3000/data")      // for cloud server, add permission to info.plist as well...see the code version instead of table version of info.plist
            
            //code to get current phone location
            var lat: Double
            var long: Double
            let locManager = CLLocationManager()
            var currentLocation: CLLocation!
            locManager.requestWhenInUseAuthorization()
            if(locManager.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse || locManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways){
                currentLocation = locManager.location
                lat = currentLocation.coordinate.latitude
                long = currentLocation.coordinate.longitude
            }
            else{
                return
            }
        
            //made changes to dataStr
            var request = URLRequest(url: url! as URL)
            request.httpMethod = "POST"
            var dataStr = ""
            dataStr = dataStr + "&beaconid=\(String(beaconID))" + "&auth=\(auth)" + "&lat=\(lat)" + "&long=\(long)"
            let encrypt = dataStr.data(using: .utf8)
            let uploadJob = URLSession.shared.uploadTask(with: request, from: encrypt!) { data, response, error in
                    if error != nil {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Connection Interrupted", message: "Looks like the connection to the server didn't work.  Do you have Internet access?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            vc.present(alert, animated: true, completion: nil)
                        }
                    }
                    else{
                        do{ // I am trying to convert what ever JSON I get into our desired templates here
                            if data != nil{
                                let jsonData = try JSONSerialization.jsonObject(with: data!, options:[]) as? [String:Any]
                                let arrayBuffer = jsonData!["recordsets"] as? [Any]
                                let immuatbleArray = arrayBuffer![0] as? NSArray
                                for i in immuatbleArray!{
                                    let dataObject = i as? NSDictionary
                                    for key in dataObject!.allKeys{
                                        beaconData[key as! String] = dataObject![key]
                                    }
                                    dArray.append(beaconData)
                                    if let location = beaconData["locname"] as? String{
                                        if !location.isEmpty && !location.contains("Hub "){
                                            destinations.append(beaconData["locname"] as! String)
                                        }
                                    }
                                    makeMatrix(template: beaconData)
                                }
                            }
                        } catch {
                            print("JSON error")
                        }
                    }
            }
            uploadJob.resume()
    
        case "getFloor":
            //trial trial
            //let url = URL(string: "http://wh-308-3922mm.dyn.wichita.edu:5000/floor")
            let url = URL(string: "http://34.16.171.175:3000/floor")
            
            //code to get current phone location
            var lat: Double
            var long: Double
            let locManager = CLLocationManager()
            var currentLocation: CLLocation!
            locManager.requestWhenInUseAuthorization()
            if(locManager.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse || locManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways){
                currentLocation = locManager.location
                lat = currentLocation.coordinate.latitude
                long = currentLocation.coordinate.longitude
            }
            else{
                return
            }
        
            //made changes to dataStr
            var request = URLRequest(url: url! as URL)
            request.httpMethod = "POST"
            var dataStr = ""
            dataStr = dataStr + "&gid=\(String(describing: beaconID))" + "&fno=\(String(describing: floorNum!))" + "&auth=\(auth)" + "&lat=\(lat)" + "&long=\(long)"
            let encrypt = dataStr.data(using: .utf8)
            let uploadJob = URLSession.shared.uploadTask(with: request, from: encrypt!) { data, response, error in
                    if error != nil {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Connection Interrupted", message: "Looks like the connection to the server didn't work.  Do you have Internet access?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            vc.present(alert, animated: true, completion: nil)
                        }
                    }
                    else{
                        do{ // I am trying to convert what ever JSON I get into our desired templates here
                            if data != nil{
                                // Here we expect a file with all the beacon numbers in it associated to the groupID
                                DispatchQueue.main.sync {
                                    image = UIImage(data: data!)
                                }
                            }
                        } catch {
                            print("Floor Plan error")
                        }
                    }
            }
            uploadJob.resume()
        case "getbeacons":
            //here becaonID is set as groupID from our main VC
            //trial trial
            //let url = URL(string: "http://wh-308-3922mm.dyn.wichita.edu:5000/beacon")
            let url = URL(string: "http://34.16.171.175:3000/beacon")
        
            //code to get current phone location
            var lat: Double
            var long: Double
            let locManager = CLLocationManager()
            var currentLocation: CLLocation!
            locManager.requestWhenInUseAuthorization()
            if(locManager.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse || locManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways){
                currentLocation = locManager.location
                lat = currentLocation.coordinate.latitude
                long = currentLocation.coordinate.longitude
            }
            else{
                return
            }
        
            //made changes to dataStr
            var request = URLRequest(url: url! as URL)
            request.httpMethod = "POST"
            var dataStr = ""
            dataStr = dataStr + "&gid=\(String(describing: beaconID))" + "&fno=\(String(describing: floorNum!))" + "&auth=\(auth)" + "&lat=\(lat)" + "&long=\(long)"
            let encrypt = dataStr.data(using: .utf8)
            let uploadJob = URLSession.shared.uploadTask(with: request, from: encrypt!) { data, response, error in
                    if error != nil {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Connection Interrupted", message: "Looks like the connection to the server didn't work.  Do you have Internet access?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            vc.present(alert, animated: true, completion: nil)
                        }
                    }
                    else{
                        do{ // I am trying to convert what ever JSON I get into our desired templates here
                            if data != nil{
                                // Here we expect a file with all the beacon numbers in it associated to the groupID
                                let attributedString = try NSAttributedString(data: data!, options: [:], documentAttributes: nil)
                                let beaconList = attributedString.string.split(separator: "\n")
                                for i in beaconList{
                                    listOfBeacon.append(Int(i)!)
                                }
                            }
                        } catch {
                            print("Beacon File error")
                        }
                    }
            }
            uploadJob.resume()
        default: break
    }
}


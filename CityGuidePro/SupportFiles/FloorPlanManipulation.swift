//
//  FloorPlanManipulation.swift
//  CityGuide
//
//  Updated by AJ
//

import Foundation
import UIKit

func extractCoordinates(currNode : Int) -> [Int]{
    var axis : [Int] = []
    
    for i in dArray{
        if i["beacon_id"] as! Int == currNode{
            if let checkerForHub = i["locname"] as? String{
                if checkerForHub.contains("Hub "){
                    let n = i["other"] as? String
                    if n != nil{
                        let components = n!.components(separatedBy: ",")
                        axis.append(Int(components[0])!)
                        axis.append(Int(components[1])!)
                    }
                }
            }
        }
    }
    
    return axis
}

// to extract locations of beacons that make up the shortest path
func SPBeaconCoordinates(currNode : Int, groupID: Int, floorNo: Int) -> [Int]{
    var axiss : [Int] = []
    
    for i in dArray{
        if i["node"] as! Int == currNode{
            if let checkerForHub = i["locname"] as? String{
                if checkerForHub.contains("Hub "){
               
                    
                    let groupIDchecker = i["group_id"] as? Int
                    let floorchecker = i["_level"] as? Int
                    
                    if groupIDchecker == groupID && floorchecker == floorNo{
                        let n = i["other"] as? String
                        if n != nil{
                            let components = n!.components(separatedBy: ",")
                            axiss.append(Int(components[0])!)
                            axiss.append(Int(components[1])!)
                        }
                        
                    }
                   
                }
            }
        }
    }
    
    return axiss
}

func drawOnImage(_ image: UIImage, x : Int, y : Int) -> UIImage{
    UIGraphicsBeginImageContext(image.size)
    image.draw(at: CGPoint.zero)
    
    // Get context here
    let context = UIGraphicsGetCurrentContext()
    
    /*
    context?.setFillColor (UIColor.blue.cgColor)
    context?.setAlpha(1.0)
    context?.setLineWidth(0.75)
    context?.addEllipse(in: CGRect(x: x, y: y, width: 14, height: 14))
    context?.drawPath(using: .fillStroke)
    */
    
    let dot_fill_color = UIColor(red: 66.0/255.0, green: 133.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    let dot_border_color = UIColor(red: 242.0/255.0, green: 244.0/255.0, blue: 253.0/255.0, alpha: 1.0)
    
    context?.setLineWidth(12.0)
    context?.setStrokeColor(dot_border_color.cgColor)
    let rectangle = CGRect(x: x, y: y, width: 30, height: 30) // Code to modify the size of the blue dot
    context?.addEllipse(in: rectangle)
    context?.strokePath()
    context?.setFillColor(dot_fill_color.cgColor)
    context?.fillEllipse(in: rectangle)

    
    // Save context as new UIImage
    let myImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return myImage!
}

// to get user location dot as well as dots that make up the shortest path to destination
func drawOnImage2(_ image: UIImage, groupID : Int, floorNo : Int, shortestPath : [Int], xCord : Int, yCord : Int) -> UIImage{
    UIGraphicsBeginImageContext(image.size)
    image.draw(at: CGPoint.zero)
    
    // Get context here
    let context2 = UIGraphicsGetCurrentContext()
    
    // variable to hold the starting point of the line
    var startPoint: CGPoint?

    
    for spnode in shortestPath{
        let spcoords = SPBeaconCoordinates(currNode: spnode, groupID: groupID, floorNo: floorNo)
        
        if (!spcoords.isEmpty){
            
                    
            /*
            let point = CGPoint(x: spcoords[0], y: spcoords[1])
            context2?.setFillColor(UIColor.systemRed.cgColor)
            //context2?.setFillColor(red: 157.0/255.0, green: 192.0/255.0, blue: 250.0/255.0, alpha: 1.0)
            context2?.fillEllipse(in: CGRect(origin: point, size: CGSize(width: 9, height: 9)))
             */
            let dot_fill_color = UIColor(red: 181.0/255.0, green: 207.0/255.0, blue: 251.0/255.0, alpha: 1.0)
            let dot_border_color = UIColor(red: 66.0/255.0, green: 133.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                        
            let dot_color_1 = UIColor(red: 84.0/255.0, green: 166.0/255.0, blue: 251.0/255.0, alpha: 1.0)
            
            // red
            let dot_color_2 = UIColor(red: 237.0/255.0, green: 28.0/255.0, blue: 36.0/255.0, alpha: 1.0)
            
            // dark blue
            let dot_color_3 = UIColor(red: 3.0/255.0, green: 28.0/255.0, blue: 244.0/255.0, alpha: 1.0)
            
            // light blue
            let dot_color_4 = UIColor(red: 116.0/255.0, green: 209.0/255.0, blue: 246.0/255.0, alpha: 1.0)
            
            // gray
            let dot_color_5 = UIColor(red: 147.0/255.0, green: 147.0/255.0, blue: 147.0/255.0, alpha: 1.0)
            
            // another light blue
            let dot_color_6 = UIColor(red: 140.0/255.0, green: 181.0/255.0, blue: 249.0/255.0, alpha: 1.0)
            
            // lighter blue
            let dot_color_7 = UIColor(red: 165.0/255.0, green: 197.0/255.0, blue: 250.0/255.0, alpha: 1.0)
            

            
            // to draw a line between each point
            if startPoint == nil {
                startPoint = CGPoint(x: spcoords[0]+6, y: spcoords[1]+6)
            } else {
                // Draw a line from the previous point to the current point
                context2?.setLineWidth(4.0)
                context2?.setStrokeColor(dot_color_7.cgColor)
                context2?.move(to: startPoint!)
                context2?.addLine(to: CGPoint(x: spcoords[0]+6, y: spcoords[1]+6))
                context2?.strokePath()
                
                // Update the start point for the next line
                startPoint = CGPoint(x: spcoords[0]+6, y: spcoords[1]+6)
            }

            
            
            // to draw the dots to the destination
            // applies to the beacon linked to the destination
            if spnode == shortestPath.dropLast().last{
                context2?.setLineWidth(0.0)
                context2?.setStrokeColor(dot_color_2.cgColor)
                let rectangle = CGRect(x: spcoords[0], y: spcoords[1], width: 12, height: 12)
                context2?.addEllipse(in: rectangle)
                context2?.strokePath()
                context2?.setFillColor(dot_color_2.cgColor)
                context2?.fillEllipse(in: rectangle)
            }
            else{
                context2?.setLineWidth(0.0)
                context2?.setStrokeColor(dot_color_7.cgColor)
                let rectangle = CGRect(x: spcoords[0], y: spcoords[1], width: 12, height: 12)
                context2?.addEllipse(in: rectangle)
                context2?.strokePath()
                context2?.setFillColor(dot_color_7.cgColor)
                context2?.fillEllipse(in: rectangle)
            }
        }
    }
    
    // to draw the current user location dot
    let dot_fill_color = UIColor(red: 66.0/255.0, green: 133.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    let dot_border_color = UIColor(red: 242.0/255.0, green: 244.0/255.0, blue: 253.0/255.0, alpha: 1.0)
    
    // blue for dot
    let dot_color_0 = UIColor(red: 22.0/255.0, green: 104.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    


    context2?.setLineWidth(12)
    context2?.setStrokeColor(dot_border_color.cgColor)
    print("Coordinates for Blue dot",xCord,yCord)
    let rectangle = CGRect(x: xCord, y: yCord, width: 30, height: 30)
    context2?.addEllipse(in: rectangle)
    context2?.strokePath()
    context2?.setFillColor(dot_color_0.cgColor)
    context2?.fillEllipse(in: rectangle)
    
    // Save context as new UIImage
    let myImage2 = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return myImage2!
}


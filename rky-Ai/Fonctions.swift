//
//  Fonctions.swift
//  rky-Ai
//
//  Created by Eric PLAIDY on 16/07/2016.
//  Copyright © 2016 eCoucou. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import CoreData

// User informations / credentials
var userId:String = "" //"1947b9f3f22eada15437123b6c1d8e283194f793234cb5e2533d109606374993"
var pseudo:String = "Ricky_Pseudo_01"
var cred = [NSManagedObject]()

// Map variables
var loc_longitude:CLLocationDegrees = 2.308216
var loc_latitude:CLLocationDegrees = 48.8338031
var loc_prev_longitude:CLLocationDegrees = 2.308216
var loc_prev_latitude:CLLocationDegrees = 48.8338031
var initialLocation = CLLocation(latitude: loc_latitude, longitude: loc_longitude)
var regionRadius: CLLocationDistance = 3000
var l_zone: CLLocationDistance = 250
var a_zone: CLLocationDistance = 400

var first = true
var startup = true
var color_ligne = UIColor.blueColor()
var color_fond = UIColor.blueColor().colorWithAlphaComponent(0.1)


struct LocData
{
    var etat:String = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var userId:String = ""
    init(){}
}
var data_loc = Array<LocData>()

// credentials update/create
func saveCredentials(userId: String, pseudo: String) {
    
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entityForName("Credentials",
                                                    inManagedObjectContext: managedContext)
    let credentials = NSManagedObject(entity: entity!,
                                      insertIntoManagedObjectContext: managedContext)
    credentials.setValue(userId, forKey: "userId")
    credentials.setValue(pseudo, forKey: "pseudo")
    
    do {
        try managedContext.save()
        cred.removeAll()
        cred.append(credentials)
    } catch let error as NSError  {
        print("Could not save \(error), \(error.userInfo)")
    }
    print(cred)
}

//fonction create UserId : fonction unique à la première ouverture de l'appli
func create_userId() {
    
    let baseURL:String = "https://rkyai.herokuapp.com/api/v1/map"
    let url: NSURL = NSURL(string: baseURL)!
    
    let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
    
    request1.HTTPMethod = "POST"
    let paramString = "{\"profil\":{\"user\":\""+pseudo + "\"}, \"latitude\":\""+String(loc_latitude)+"\", \"longitude\":\""+String(loc_longitude)+"\"}"
    request1.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
    request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request1){ data, response, error in
        
        do {

            // check reponse du serveur
            // let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            // print(dataString)
            
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers ) as? NSDictionary {
                // apres creation user recuperation du userId
                userId = jsonResult["userId"] as! String
//                for item in jsonResult {
//                    print(item)
//                }
            } else {
                print("bordel")
            }
        
            // code ici

        } catch let error as NSError {
            print(error.localizedDescription)
        }
        dispatch_async(dispatch_get_main_queue(), {
            // code ici !
            saveCredentials(userId, pseudo: pseudo)
            return
        })
    }
    task.resume()
}
//fonction create UserId : fonction unique à la première ouverture de l'appli
func update_userId(etat:String) {
    
    let baseURL:String = "https://rkyai.herokuapp.com/api/v1/map/"+userId
    let url: NSURL = NSURL(string: baseURL)!
    
    let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
    
    request1.HTTPMethod = "PUT"
    let paramString = "{\"latitude\":\""+String(loc_latitude)+"\", \"longitude\":\""+String(loc_longitude)+"\", \"etat\":\""+etat+"\",\"type\":\"user\",\"profil\": {\"user\":\""+pseudo+"\"}}"
    print(paramString)
    print(baseURL)
    request1.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
    request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request1){ data, response, error in
        
        do {
            
            // check reponse du serveur
//             let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//             print(dataString)
/*
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers ) as? NSDictionary {
//
            } else {
                print("bordel")
            }
*/
            // code ici
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        dispatch_async(dispatch_get_main_queue(), {
            // code ici !
            return
        })
    }
    task.resume()
}
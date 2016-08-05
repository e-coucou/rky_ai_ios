//
//  ViewController.swift
//  rky-Ai
//
//  Created by Eric PLAIDY on 16/07/2016.
//  Copyright © 2016 eCoucou. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var maps: MKMapView!
    @IBOutlet weak var info_text: UILabel!

    let locationManager = CLLocationManager()

    @IBAction func change_pseudo(sender: AnyObject) {
        update_userId("safe")
    }
    
    @IBAction func back_origine(button: actionButton) {
        switch button.numButton {
        case 0:
            regionRadius = 1000
            centerMapOnLocation(CLLocation(latitude: loc_latitude, longitude: loc_longitude))
        case 1:
            regionRadius=100000
            get_userId()
        case 2:
            regionRadius=5000
            update_userId("safe")
        case 3:
            regionRadius=5000
            update_userId("unsafe")
        case 4:
            regionRadius=5000
            update_userId("alerte")
        case 5:
            regionRadius=5000
            update_userId("terror")
        default:
            print("no button")
        }
        get_userId()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        maps.delegate = self

        // For use in foreground
        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.requestWhenInUseAuthorization()
        print("Start location !")
        if CLLocationManager.locationServicesEnabled() {
            print("Location enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Credentials")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            cred = results as! [NSManagedObject]
            print(cred)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if cred != [] {
            let credentials = try cred[0]
            userId = (credentials.valueForKey("userId") as? String)!
            pseudo = (credentials.valueForKey("pseudo") as? String)!
            first=false
        } else {
            print("no credentials")
        }
//        self.userId.text = userId
        self.info_text.text = pseudo
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        maps.setRegion(coordinateRegion, animated: true)
    }
    
    func drawZone(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance, etat: String){
        
        let cir_zone:MKCircle = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: latitude, longitude:longitude), radius: radius)
        maps.addOverlay(cir_zone)
        print("overlay add")
        
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        loc_prev_latitude = loc_latitude
        loc_prev_longitude = loc_longitude
        
        loc_latitude = locValue.latitude
        loc_longitude = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if (first) {
            first = false
            create_userId()
        } else {
            update_userId("safe")
        }
        //stop updating location to save battery life
//        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        if (startup) {
            centerMapOnLocation(CLLocation(latitude: loc_latitude, longitude: loc_longitude))
            startup = false
        }
        let overlays = maps.overlays
        maps.removeOverlays(overlays)

        color_ligne = UIColor.blueColor()
        color_fond = UIColor.blueColor().colorWithAlphaComponent(0.1)
        let cir_zone:MKCircle = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: loc_latitude, longitude:loc_longitude), radius: l_zone)
        maps.addOverlay(cir_zone)
    }
    //fonction get userId (all)
    func get_userId() {
        var new_data:LocData
        new_data = LocData()
        
        let baseURL:String = "https://rkyai.herokuapp.com/api/v1/search?user=*&record=map&etat=*"
        let url: NSURL = NSURL(string: baseURL)!
        print(baseURL)
        
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        let formatter = NSNumberFormatter()
        formatter.decimalSeparator = "."
        
        info_text.text = "Waiting for data"
        
        request1.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request1){ data, response, error in
            do {
                //            print("response get ok")
                data_loc.removeAll()
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: [] ) as? NSArray {
                    let overlays = self.maps.overlays
                    self.maps.removeOverlays(overlays)
                    for item in jsonResult {
                        //                    print(item["latitude"] as! String)
                        new_data.etat = item["etat"] as! String
                        new_data.latitude = Double(formatter.numberFromString(item["latitude"] as! String)!)
                        new_data.longitude = Double(formatter.numberFromString(item["longitude"] as! String)!)
//                        new_data.userId=item["userId"] as! String
                        data_loc.append(new_data)
                    }
                }
                for data in data_loc {
                    print(data.latitude,data.longitude)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.drawZoneAll()
                self.info_text.text = pseudo
                return
            })
//        })
        }
        task.resume()
    }
    
    func drawZoneAll() {
        for item in data_loc {
            switch item.etat {
            case "safe":
                color_ligne = UIColor.greenColor()
                color_fond = UIColor.greenColor().colorWithAlphaComponent(0.1)
            case "unsafe":
                color_ligne = UIColor.yellowColor()
                color_fond = UIColor.yellowColor().colorWithAlphaComponent(0.1)
            case "alerte":
                color_ligne = UIColor.redColor()
                color_fond = UIColor.redColor().colorWithAlphaComponent(0.1)
            case "terror":
                color_ligne = UIColor.blackColor()
                color_fond = UIColor.blackColor().colorWithAlphaComponent(0.1)
            default:
                color_ligne = UIColor.grayColor()
                color_fond = UIColor.grayColor().colorWithAlphaComponent(0.1)
            }
            self.drawZone(item.latitude, longitude: item.longitude, radius: a_zone, etat: item.etat)
        }
        self.centerMapOnLocation(CLLocation(latitude: loc_latitude, longitude: loc_longitude))
        self.locationManager.stopUpdatingLocation()
    }
}
// VC extension
//
extension ViewController: MKMapViewDelegate {
 
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let overlayRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.0
        overlayRenderer.strokeColor = color_ligne
        overlayRenderer.fillColor = color_fond
//        overlayRenderer.strokeColor = UIColor.blueColor()
//        overlayRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        return overlayRenderer
    }

}

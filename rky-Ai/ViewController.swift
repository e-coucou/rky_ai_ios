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

class ViewController: UIViewController {

    @IBOutlet weak var maps: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maps.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        centerMapOnLocation(initialLocation)
        var cir_zone:MKCircle = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: loc_latitude, longitude:loc_longitude), radius: l_zone)
        maps.addOverlay(cir_zone)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        maps.setRegion(coordinateRegion, animated: true)
    }


}
// VC extension
//
extension ViewController: MKMapViewDelegate {
 
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let overlayRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.0
        overlayRenderer.strokeColor = UIColor.blueColor()
        overlayRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        return overlayRenderer
    }

}

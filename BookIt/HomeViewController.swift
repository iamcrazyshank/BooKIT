//
//  HomeViewController.swift
//  BookIt
//
//  Created by Shashank Chandran on 12/24/18.
//  Copyright © 2018 Shashank Chandran. All rights reserved.
//UIViewController , GMSMapViewDelegate ,  CLLocationManagerDelegate


import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

enum Location {
    case startLocation
    case destinationLocation
}

class HomeViewController: UIViewController , GMSMapViewDelegate ,  CLLocationManagerDelegate ,UICollectionViewDataSource, UICollectionViewDelegate , GMSAutocompleteViewControllerDelegate{
    
    @IBOutlet weak var cabCollectionView: UICollectionView!
    var CabArray = [UIImage(named: "cab 1"),UIImage(named: "cab 3"),UIImage(named: "cab 2")]
    //  let randomPrice = Int.random(in: 0..<500)
    var PriceArray = (1...10).map{_ in arc4random_uniform(100)}
    //var PriceArray = [200,300,400]
    var locationManager = CLLocationManager()
    var locationSelected = Location.destinationLocation
    var locationCurrent = Location.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    @IBOutlet weak var googleMaps: GMSMapView!
    
    
    @IBAction func destination(_ sender: Any) {
        
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        locationSelected = .destinationLocation
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        let camera = GMSCameraPosition.camera(withLatitude: -7.9292222, longitude: 142.5871122, zoom: 15.0)
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        googleMaps.isMyLocationEnabled = true
        googleMaps.delegate = self
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        locationStart = locations.last ?? location!
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
        
        marker.map = googleMaps
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:30)
        googleMaps.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    
    func createMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.map = googleMaps
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }
    
    
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {print("..................................................")
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        print(origin)
        print(destination)
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyClAJAbWURdK-iDawYJU6ksjbZpfQOFuJM"
      
       
        Alamofire.request(url).responseJSON { response in
          
            do {
                let json = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSDictionary
                
                let routes = (json.object(forKey: "routes") as! NSArray)
                
                if routes.count > 0 {
                   
                    if let route = ((routes.object(at: 0) as? NSDictionary)?.object(forKey: "overview_polyline") as? NSDictionary)?.value(forKey: "points") as? String {
                       
                    self.googleMaps.clear()
                        
                        let path  = GMSPath(fromEncodedPath:route)!
                        let polyline  = GMSPolyline(path: path)
                        polyline.strokeColor = UIColor.black
                        polyline.strokeWidth = 5.0
                        polyline.map = self.googleMaps
                        
                    }
                    
                }
                
            } catch { print(error)
            }
            self.cabCollectionView.isHidden = false
        }

        
        
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CabArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cabCollectionView.isHidden = true
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideCell", for: indexPath) as! RideCell
        cell.cabImage.image = CabArray[indexPath.row]
        
        cell.cabPrice.text = "Rs." + String(PriceArray[indexPath.row])
        return cell
    }
    var flag = 0
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cabCollectionView.allowsMultipleSelection = false
        let cell = collectionView.cellForItem(at: indexPath)
        flag = 1
    }
    
    
    @IBAction func RideNow(_ sender: Any) {
        
        if (flag == 1){
            let alert = UIAlertController(title: "Ride Book", message: "You're ride is booked", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            flag = 0
        }else{
            let alert = UIAlertController(title: "Select taxi", message: "waiting...", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}

extension HomeViewController {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 30
        )
        locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        createMarker(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.googleMaps.camera = camera
        self.dismiss(animated: true, completion: nil)
        self.drawPath(startLocation: locationStart,endLocation: locationEnd)
        
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

//
//  LocationsViewController.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var footerView: UIView!

    
    var dataController:DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Virtual Tourist"
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        footerView.isHidden = true
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        setupFetchedResultsController()
        showPins()
        loadMapRegion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        footerView.isHidden = !editing
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        if (sender.state == .began  && !(self.isEditing)){
            
            
            let pinLocation = sender.location(in: self.mapView)
            let pinCoordinate = self.mapView.convert(pinLocation, toCoordinateFrom: self.mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = pinCoordinate.latitude
            pin.longitude = pinCoordinate.longitude
            pin.creationDate = Date()
            try?dataController.viewContext.save()
            
        }
    }
    
    /// Delete the Pin at the specified index path
    func deletePin(_ pinToDelete: Pin) {
        
        //let pinToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(pinToDelete)
        try?dataController.viewContext.save()
    }
    
    func showPins(){
        
        var annotations = [MKPointAnnotation]()
        
        for location in fetchedResultsController.fetchedObjects! {
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    
    private func fetchPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = dataController.fetchPin(predicate)
        } catch {
            print("\(#function) error:\(error)")
            // showInfo(withTitle: "Error", withMessage: "Error while fetching location: \(error)")
        }
        return pin
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AlbumViewController {
            guard let pin = sender as? Pin else {
                return
            }
            //let controller = segue.destination as! PhotoAlbumViewController
            vc.pin = pin
            vc.dataController = dataController
        }
    }
    
    
    
    
    // restore map center and zoom level
    func loadMapRegion() {
        
        let defaults = UserDefaults.standard
        if let dict = defaults.dictionary(forKey: "mapRegion"),
            let myRegion = MKCoordinateRegion(decode: dict as [String : AnyObject]) {
            
            // do something with myRegion
            mapView.setRegion(myRegion, animated: true)
            
        }
    }
    
    // save map center and zoom level
    func saveMapRegion() {
        
        let defaults = UserDefaults.standard
        defaults.set(mapView.region.encode, forKey: "mapRegion")
        
    }
}

extension LocationsViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = false
            annotationView!.animatesDrop = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        
        
        return annotationView
    }
    
    
    func addAnnotation(_ pinCoordinate:CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoordinate
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(annotation)
            
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else{ return}
        
        if let selectedPin = fetchPin(latitude: "\(annotation.coordinate.latitude)", longitude: "\(annotation.coordinate.longitude)"){
            
            
            
            if(self.isEditing){
                
                deletePin(selectedPin)
                
                performUIUpdatesOnMain {
                    self.mapView.deselectAnnotation(annotation, animated: true)
                    self.mapView.removeAnnotation(annotation)
                    
                }
                
            }else{
                
                self.mapView.deselectAnnotation(annotation, animated: true)
                performSegue(withIdentifier: "showAlbum", sender: selectedPin)
                
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // save the map center and zoom level as soon as the map region has changed
        saveMapRegion()
    }
}

extension LocationsViewController: NSFetchedResultsControllerDelegate{
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        var pinCoordinate: CLLocationCoordinate2D!
        
        if let pin = anObject as? Pin{
            
            pinCoordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        } else {
            fatalError("error changed object is not Pin")
        }
        
        switch type {
            
        case .insert:
            print("Pin inserted!")
            self.addAnnotation(pinCoordinate)
            
        case .delete:
            print("Pin deleted!")
            
        case .update:
            print("Pin updated!")
            
        case .move:
            print("Pin moved!")
            
        }
    }

}

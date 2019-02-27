//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import UIKit
import MapKit


extension UIViewController {
    
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /**
     Property used to identify the activity indicator. Default valye is `999999`
     but this can be overridden.
     */
    public var activityIndicatorTag: Int { return 999999 }
    
    /**
     Creates and starts an UIActivityIndicator in any UIViewController
     Parameter style: `UIActivityIndicatorViewStyle` default is .whiteLarge
     Parameter location: `CGPoint` if not specified the `view.center` is applied
     */
    public func startActivityIndicator(_ style: UIActivityIndicatorView.Style = .whiteLarge, location: CGPoint? = nil) {
        
        let loc = location ?? self.view.center
        
        DispatchQueue.main.async(execute: {
            let activityIndicator = UIActivityIndicatorView(style: style)
            activityIndicator.tag = self.activityIndicatorTag
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        })
    }
    
    /**
     Stops and removes an UIActivityIndicator in any UIViewController
     */
    public func stopActivityIndicator() {
        
        DispatchQueue.main.async(execute: {
            if let activityIndicator = self.view.subviews.filter({ $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        })
    }
}


extension MKCoordinateRegion {
    
    var encode:[String: Any] {
        return ["center":
            ["latitude": self.center.latitude,
             "longitude": self.center.longitude],
                "span":
                    ["latitudeDelta": self.span.latitudeDelta,
                     "longitudeDelta": self.span.longitudeDelta]]
    }
    
    init?(decode: [String: AnyObject]) {
        
        guard let center = decode["center"] as? [String: AnyObject],
            let latitude = center["latitude"] as? Double,
            let longitude = center["longitude"] as? Double,
            let span = decode["span"] as? [String: AnyObject],
            let latitudeDelta = span["latitudeDelta"] as? Double,
            let longitudeDelta = span["longitudeDelta"] as? Double
            else { return nil }
        
        
        self.init()
        self.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}

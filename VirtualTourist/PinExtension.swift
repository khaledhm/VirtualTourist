//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import CoreData
import MapKit

extension Pin: MKAnnotation{
    public var coordinate: CLLocationCoordinate2D {
        
        let latDeg = CLLocationDegrees(latitude)
        let longDeg = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDeg, longitude: longDeg)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    
    
}

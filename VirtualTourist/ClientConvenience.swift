//
//  ClientConvenience.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import Foundation


extension Client {
    
    func searchPhotosFormFlickerBy(latitude:Double ,longitude:Double,totalPages: Int?, _ completionHandlerForFlickerPhoto: @escaping (_ success: Bool,_ photoData: Any?, _ errorString: String?) -> Void) {
        
        
        // get random page.
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/Constants.FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        
        let bBox = self.bboxString(latitude: latitude, longitude: longitude)
        
        let parameters = [
            Constants.FlickrParameterKeys.Method           : Constants.FlickrParameterValues.SearchMethod
            , Constants.FlickrParameterKeys.APIKey         : Constants.FlickrParameterValues.APIKey
            , Constants.FlickrParameterKeys.Format         : Constants.FlickrParameterValues.ResponseFormat
            , Constants.FlickrParameterKeys.Extras         : Constants.FlickrParameterValues.MediumURL
            , Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParameterValues.DisableJSONCallback
            , Constants.FlickrParameterKeys.SafeSearch     : Constants.FlickrParameterValues.UseSafeSearch
            , Constants.FlickrParameterKeys.BoundingBox    : bBox
            , Constants.FlickrParameterKeys.PhotosPerPage  : Constants.FlickrParameterValues.PhotosPerPage
            , Constants.FlickrParameterKeys.Page           : "\(page)"
            ] as [String : Any]
        
        /* 2. Make the request */
        
        _ = taskForGETMethod( parameters: parameters as [String : AnyObject] , decode: Response.self) { (result, error) in
            
            if let error = error {
                completionHandlerForFlickerPhoto(false ,nil,"\(error.localizedDescription)")
                
            }else {
                let newResult = result as! Response
                
                let resultData = newResult.photos!.photo
                
                if newResult.photos!.photo.isEmpty {
                    completionHandlerForFlickerPhoto(true, nil, nil)
                    
                } else {
                    completionHandlerForFlickerPhoto(true ,newResult, nil)
                }
                
            }
        }
        
    }
    
}

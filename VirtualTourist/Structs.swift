//
//  Structs.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import Foundation

struct Response: Codable {
    let photos : Photos?
    let stat: String
}

struct Photos: Codable {
    let photo : [FlickrURL]
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
}

struct FlickrURL: Codable {
    let url: String?
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_m"
        case id
    }
}

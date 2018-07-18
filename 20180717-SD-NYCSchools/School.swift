//
//  Schools.swift
//  20180717-SD-NYCSchools
//
//  Created by Sean Donato on 7/17/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

import Foundation

struct School {
    
    let name: String
    let latitude: Double
    let longitude: Double
    let email: String
    let phone: String
    let location: String
    let website: String
    let overview: String
    let dbn: String


    //initialize properties
    init(dictionary: [String: Any]) {
        
        self.name = dictionary["school_name"] as? String ?? ""
        
        //remove dashed from phone number
        var phoneString = dictionary["phone_number"] as? String ?? ""
        
        phoneString = phoneString.replacingOccurrences(of: "-", with: "")

        self.phone = phoneString

        //convert geo coordinates from string to double and setting a default coordinate for Manhattan
        let lat = dictionary["latitude"] as? String ?? "40.755337"
        
        self.latitude = Double(lat)!
        
        let lon = dictionary["longitude"] as? String ?? "-73.995409"
        
        self.longitude = Double(lon)!
        
        //some cities and neighborhood seemed to be the same string, such as Epic High School in "South Ozone Park", so here I check
        let neighborhood = dictionary["neighborhood"] as? String ?? ""
        let city = dictionary["city"] as? String ?? "New York"
        
        if(neighborhood.elementsEqual(city)){
            location = neighborhood
        }else{
            location = neighborhood + ", " + city
        }
        
        var site = dictionary["website"] as? String ?? ""
        
        
        if site.range(of:"https://") == nil {

            if site.range(of:"http://") != nil{
               site = site.replacingOccurrences(of: "http://", with: "https://")
            }else{
                
                site = "https://" + site
            }
        }
        
        self.website = dictionary["website"] as? String ?? ""
        

        self.email = dictionary["school_email"] as? String ?? ""

        self.dbn = dictionary["dbn"] as? String ?? ""

        self.overview = dictionary["overview_paragraph"] as? String ?? ""

    }

}

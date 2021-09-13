//
//  CLLocation+toCD.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 29/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import CoreData

extension CLLocation {
    func toCD(context: NSManagedObjectContext) -> CDLocation {
        (NSEntityDescription.insertNewObject(forEntityName: "CDLocation", into: context) as! CDLocation).then({
            $0.date = self.timestamp
            $0.latitude = self.coordinate.latitude
            $0.longitude = self.coordinate.longitude
            $0.accuracy = self.horizontalAccuracy
        })
    }
}
    
    


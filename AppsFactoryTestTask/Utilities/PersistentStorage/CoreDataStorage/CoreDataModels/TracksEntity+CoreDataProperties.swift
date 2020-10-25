//
//  TracksEntity+CoreDataProperties.swift
//  
//
//  Created by Turgut Ekmekci on 17.11.2019.
//
//

import Foundation
import CoreData


extension TracksEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TracksEntity> {
        return NSFetchRequest<TracksEntity>(entityName: "TracksEntity")
    }

    @NSManaged public var artistName: String?
    @NSManaged public var duration: String?
    @NSManaged public var trackName: String?
    @NSManaged public var album: AlbumEntity?

}

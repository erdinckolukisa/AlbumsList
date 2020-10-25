//
//  TracksEntity+CoreDataProperties.swift

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

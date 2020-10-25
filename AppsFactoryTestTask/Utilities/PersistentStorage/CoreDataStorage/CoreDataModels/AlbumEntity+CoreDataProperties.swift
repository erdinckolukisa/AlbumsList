//
//  AlbumEntity+CoreDataProperties.swift
//  
//
//  Created by Turgut Ekmekci on 17.11.2019.
//
//

import Foundation
import CoreData


extension AlbumEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlbumEntity> {
        return NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
    }

    @NSManaged public var albumImage: NSData?
    @NSManaged public var name: String?
    @NSManaged public var artistName: String?
    @NSManaged public var mbid: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var albumDescription: String?
    @NSManaged public var tracks: NSSet?

}

// MARK: Generated accessors for tracks
extension AlbumEntity {

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: TracksEntity)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: TracksEntity)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSSet)

}

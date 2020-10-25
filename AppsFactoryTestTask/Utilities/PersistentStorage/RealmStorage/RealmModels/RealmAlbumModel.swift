//
//  RealmAlbumModel.swift

import Foundation
import RealmSwift

class RealmAlbumModel: Object {
    @objc dynamic var albumImage: NSData?
    @objc dynamic var name: String?
    @objc dynamic var artistName: String?
    @objc dynamic var mbid: String?
    @objc dynamic var createdAt: NSDate?
    @objc dynamic var albumDescription: String?
    let tracks = List<RealmTrackModel>()
}

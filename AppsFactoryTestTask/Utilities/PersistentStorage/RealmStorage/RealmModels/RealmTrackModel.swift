//
//  RealmTrackModel.swift

import Foundation
import RealmSwift

class RealmTrackModel: Object {
    @objc dynamic var artistName: String?
    @objc dynamic var duration: String?
    @objc dynamic var trackName: String?
}

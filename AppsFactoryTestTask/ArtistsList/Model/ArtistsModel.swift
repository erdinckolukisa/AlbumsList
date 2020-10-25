//
//  ArtistsModel.swift

import Foundation
struct ArtistMatches: Decodable {
    var artist: [Artist]?
}

struct Artist: Decodable {
    var name: String?
    var listeners: String?
    var mbid: String?
    var url: String?
    var streamable: String?
    var image: [ImageModel]?
}

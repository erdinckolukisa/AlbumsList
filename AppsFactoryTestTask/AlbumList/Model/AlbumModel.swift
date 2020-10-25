//
//  AlbumModel.swift

import Foundation

struct TopAlbums: Decodable {
    var album: [Album]?
    
    enum CodingKeys: String, CodingKey {
        case topAlbums = "topalbums"
        case album = "album"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let results = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .topAlbums)
        album = try results.decode([Album].self, forKey: .album)
    }
}

struct Album: Decodable {
    var mbid: String?
    var name: String?
    var url: String?
    var playCount: String?
    var image: [ImageModel]?
}

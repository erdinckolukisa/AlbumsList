//
//  AlbumDetailModel.swift

import Foundation

class AlbumDetailModel: Decodable {
    var mbid: String
    var albumName: String?
    var artistName: String?
    var images: [ImageModel]?
    var imageData: Data?
    var wikiPublishedDate: String?
    var wikiSummary: String?
    var wikiContent: String?
    var albumTracks: [Track]?
    
    init(albumEntity: AlbumEntity) {
        self.mbid = albumEntity.mbid
        self.albumName = albumEntity.name
        self.artistName = albumEntity.artistName
        self.imageData = albumEntity.albumImage as Data?
        self.wikiSummary = albumEntity.albumDescription
        albumTracks = [Track]()
        albumEntity.tracks?.forEach({ track in
            if let albumEntityTrack = track as? TracksEntity {
                albumTracks?.append(Track(name: albumEntityTrack.trackName ?? "uknown", duration: albumEntityTrack.duration ?? "0", artistName: albumEntityTrack.artistName ?? "uknown"))
            }
        })
    }
    
    init(realmAlbum: RealmAlbumModel) {
        // - this part may be solved by using failable init after the initial realm implemantation
        self.mbid = realmAlbum.mbid ?? ""
        self.albumName = realmAlbum.name
        self.artistName = realmAlbum.artistName
        self.imageData = realmAlbum.albumImage as Data?
        self.wikiSummary = realmAlbum.albumDescription
        albumTracks = [Track]()
        realmAlbum.tracks.forEach({ track in
            albumTracks?.append(Track(name: track.trackName ?? "uknown", duration: track.duration ?? "0", artistName: track.artistName ?? "uknown"))
        })
    }

    enum CodingKeys: String, CodingKey {
        case album = "album"
        case mbid = "mbid"
        case albumName = "name"
        case artistName = "artist"
        case images = "image"
        case wiki
        case wikiPublishedDate = "published"
        case wikiSummary = "summary"
        case wikiContent = "content"
        case tracks
        case albumTracks = "track"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let results = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .album)
        mbid = try results.decode(String.self, forKey: .mbid)
        albumName = try results.decode(String.self, forKey: .albumName)
        artistName = try results.decode(String.self, forKey: .artistName)
        images = try results.decode([ImageModel].self, forKey: .images)
        
        if results.contains(.wiki) {
            let wikiContainer = try results.nestedContainer(keyedBy: CodingKeys.self, forKey: .wiki)
            wikiPublishedDate = try wikiContainer.decode(String.self, forKey: .wikiPublishedDate)
            wikiSummary =  try wikiContainer.decode(String.self, forKey: .wikiSummary)
            wikiContent = try wikiContainer.decode(String.self, forKey: .wikiContent)
        }
        
        if results.contains(.tracks) {
            let trackContainer = try results.nestedContainer(keyedBy: CodingKeys.self, forKey: .tracks)
            albumTracks = try trackContainer.decode([Track].self, forKey: .albumTracks)
        }
    }
}

class Track: Decodable {
    var name: String?
    var duration: String?
    var artistName: String?
    
    init(name: String, duration: String, artistName: String) {
        self.name = name
        self.duration = duration
        self.artistName = artistName
    }
    enum CodingKeys: String, CodingKey {
        case artist
        case artistName = "name"
    }
    
    enum AlbumKeys: String, CodingKey {
        case name = "name"
        case duration = "duration"
    }
    
    required init(from decoder: Decoder) throws {
        let artistContainer = try decoder.container(keyedBy: CodingKeys.self)
        let results = try artistContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .artist)
        artistName = try results.decode(String.self, forKey: .artistName)
        
        let container = try decoder.container(keyedBy: AlbumKeys.self)
        name = try container.decode(String.self, forKey: .name)
        duration = try container.decode(String.self, forKey: .duration)
    }
}

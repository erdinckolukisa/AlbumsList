//
//  ArtistsCellViewModel.swift

import Foundation

struct ArtistsCellViewModel {
    var mbid: String
    var artistName: String
    var artistPhotoURL: String?
    init?(mbid: String?, artistName: String?, artistPhotoURL: String?) {
        guard let mbid = mbid, let artistName = artistName else { return nil}
        self.mbid = mbid
        self.artistName = artistName
        self.artistPhotoURL = artistPhotoURL
    }
}

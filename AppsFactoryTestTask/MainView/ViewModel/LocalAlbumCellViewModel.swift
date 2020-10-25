//
//  MainViewLocalAlbumCellViewModel.swift

import Foundation

class LocalAlbumCellViewModel {
    var mbid: String?
    var albumName: String?
    var imageData: Data?
    
    init?(album: LocalAlbumModel) {
        guard let albumName = album.albumName, let albumId = album.mbid else { return nil}
        self.mbid = albumId
        self.albumName = albumName
        self.imageData = album.imageData
    }
}

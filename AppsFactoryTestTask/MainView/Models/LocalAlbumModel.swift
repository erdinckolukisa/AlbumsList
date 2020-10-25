
//
//  MainViewLocalAlbumModel.swift

import Foundation

class LocalAlbumModel {
    var mbid: String?
    var albumName: String?
    var imageData: Data?
    
    init(mbid: String, albumName: String, imageData: Data?) {
        self.mbid = mbid
        self.albumName = albumName
        self.imageData = imageData
    }
}

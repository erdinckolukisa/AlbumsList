//
//  Persistable.swift

import Foundation

protocol Persistable {
    func saveAlbum(album: AlbumDetailModel, completion: @escaping (Error?) -> ())
    func getAllAlbums(completion: @escaping ([LocalAlbumModel]?, Error?) -> ())
    func isAlbumsSaved(mbid: String, completion: @escaping (Bool, Error?) -> ())
    func deleteAlbum(mbid: String, completion: @escaping () -> ())
    func getAlbumDetail(albumId mbid: String, completion: @escaping (AlbumDetailModel?, Error?) -> ())
}

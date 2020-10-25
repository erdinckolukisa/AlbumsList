//
//  Networking.swift

import Foundation

protocol Networkable {
    func searchArtists(searchText: String, completion: @escaping (BaseSearchResultModel<ArtistMatches>?, Error?) -> ())
    func getTopAlbums(artistId mbid: String, completion: @escaping (TopAlbums?, Error?) -> ())
    func getAlbumDetail(albumId mbid: String, completion: @escaping (AlbumDetailModel?, Error?) -> ())
}

//
//  StubApi.swift

import Foundation

class StubApi: Networkable {
    // MARK: - GetAlbumDetail
    func getAlbumDetail(albumId mbid: String, completion: @escaping (AlbumDetailModel?, Error?) -> ()) {
        readFromStubFile(fileName: "albumDetail", completion: { result, error in
            DispatchQueue.main.async {
                completion(result, error)
            }
        })
    }
    
    // MARK: - GetTopAlbums
    func getTopAlbums(artistId mbid: String, completion: @escaping (TopAlbums?, Error?) -> ()) {
        readFromStubFile(fileName: "topAlbums", completion: { result, error in
            DispatchQueue.main.async {
                completion(result, error)
            }
        })
    }
    
    // MARK: - SearchArtists
    func searchArtists(searchText: String, completion: @escaping (BaseSearchResultModel<ArtistMatches>?, Error?) -> ()) {
        readFromStubFile(fileName: "artistSearch", completion: { result, error in
            DispatchQueue.main.async {
                completion(result, error)
            }
        })
    }
    
    // MARK: - Read local json implementation
    private func readFromStubFile<T: Decodable>(fileName: String, completion: (_ result: T?, _ error: Error?) -> ()) {
        let jsonUrl = Bundle.main.url(forResource: fileName, withExtension: "json")
        do {
            let jsonData = try Data(contentsOf: jsonUrl!)
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: jsonData)
            completion(object, nil)
        } catch {
            completion(nil, error)
        }
    }
    
}

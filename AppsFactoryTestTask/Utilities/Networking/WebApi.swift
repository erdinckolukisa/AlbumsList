//
//  WebApi.swift

import UIKit
import Alamofire

class WebApi: Networkable {
    private let apiKey = "2740cb166b7a6f02a0cbf7510c13e9c4"
    var urlComponents = URLComponents()
    
    init() {
        urlComponents.scheme = "http"
        urlComponents.host = "ws.audioscrobbler.com"
        urlComponents.path = "/2.0/"
    }
    
    // MARK: - SearchArtists
    func searchArtists(searchText: String, completion: @escaping (BaseSearchResultModel<ArtistMatches>?, Error?) -> ()) {
       
        urlComponents.queryItems = [
            URLQueryItem(name: "method", value: "artist.search"),
            URLQueryItem(name: "artist", value: searchText),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = urlComponents.url else { return }
        post(url: url, completion: { result, error in
            DispatchQueue.main.async {
                completion(result, error)
            }
        })
    }
    
     // MARK: - GetTopAlbums
    func getTopAlbums(artistId mbid: String, completion: @escaping (TopAlbums?, Error?) -> ()) {
        
        urlComponents.queryItems = [
            URLQueryItem(name: "method", value: "artist.gettopalbums"),
            URLQueryItem(name: "mbid", value: mbid),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = urlComponents.url else { return }
        post(url: url, completion: { result, error in
            DispatchQueue.main.async {
                completion(result, error)
            }
        })
    }
    
    // MARK: - GetAlbumDetail
    func getAlbumDetail(albumId mbid: String, completion: @escaping (AlbumDetailModel?, Error?) -> ()) {
        
        urlComponents.queryItems = [
            URLQueryItem(name: "method", value: "album.getinfo"),
            URLQueryItem(name: "mbid", value: mbid),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = urlComponents.url else { return }
        post(url: url, completion: { result, error in
            DispatchQueue.main.async {
                completion(result, error)
            }
        })
        
    }
    
    // MARK: - Alamofire implementation
    private func post<T: Decodable>(url: URL, completion: @escaping (_ data: T?,_ error: Error?) -> ()) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        Alamofire.request(url).validate(statusCode: 200..<300)
            .responseData { response in
                guard let tmpData = response.data else {completion(nil, response.error); return}
                let decodable = JSONDecoder()
                switch response.result {
                case .success:
                    do {
                        let object = try decodable.decode(T.self, from: tmpData)
                        completion(object, nil)
                    } catch {
                        do {
                            let object = try decodable.decode(CustomErrorModel.self, from: tmpData)
                            let customError = CustomErrorCreator.createError(customErrorModel: object)
                            completion(nil, customError)
                        } catch {
                            print("Unable to parse data \(error)")
                            completion(nil, CustomErrorCreator.createDefaulError())
                        }
                       
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                    if let err = err as? URLError, err.code  == URLError.Code.notConnectedToInternet {
                         let customError = CustomErrorCreator.createError(errorMessage: "Internet connection error!".localizedString)
                        completion(nil, customError)
                    } else {
                        do {
                            let object = try decodable.decode(CustomErrorModel.self, from: tmpData)
                            let customError = CustomErrorCreator.createError(customErrorModel: object)
                            completion(nil, customError)
                        } catch {
                            print("Unable to parse data \(error)")
                            completion(nil, error)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
        }
    }
}

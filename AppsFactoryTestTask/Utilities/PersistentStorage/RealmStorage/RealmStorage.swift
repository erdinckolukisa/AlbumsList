//
//  RealmStorage.swift

import Foundation
import RealmSwift
import AlamofireImage
class RealmStorage: Persistable {
    let downloader = ImageDownloader()
    private var realm: Realm
    init() {
        do {
            realm = try Realm()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    func saveAlbum(album: AlbumDetailModel, completion: @escaping (Error?) -> ()) {
        if getAlbumById(mbid: album.mbid).count > 0{
            completion(nil)
            return
        }
        
        let error = NSError(domain:"", code: -1, userInfo:[NSLocalizedDescriptionKey: "An error occured. Plase try again later.".localizedString])
        let realmAlbum = RealmAlbumModel()
        
        realmAlbum.mbid = album.mbid
        realmAlbum.name = album.albumName
        realmAlbum.artistName = album.artistName
        realmAlbum.albumDescription = album.wikiSummary
        realmAlbum.createdAt = Date() as NSDate
        
        album.albumTracks?.forEach({ track in
            let realmTrack = RealmTrackModel()
            realmTrack.artistName = track.artistName
            realmTrack.trackName = track.name
            realmTrack.duration = track.duration
            realmAlbum.tracks.append(realmTrack)
        })
        
        guard let url = URL(string: album.images?.last?.url ?? "") else {
            
            try? realm.write {
                realm.add(realmAlbum)
            }
            
            completion(error)
            return
        }
        let urlRequest = URLRequest(url: url)
        self.downloader.download(urlRequest) { [weak self] response in
            if let imageData = response.data {
                realmAlbum.albumImage = imageData as NSData
            }
            try! self?.realm.write {
                self?.realm.add(realmAlbum)
            }
            completion(nil)
        }
        
        
        
    }
    
    func getAllAlbums(completion: @escaping ([LocalAlbumModel]?, Error?) -> ()) {
        let albums = realm.objects(RealmAlbumModel.self).sorted(byKeyPath: "createdAt", ascending: false)
        let albumModels = albums.compactMap { LocalAlbumModel(mbid: $0.mbid ?? "", albumName: $0.name ?? "", imageData: $0.albumImage as Data?) }
        completion(Array(albumModels), nil)
    }
    
    func isAlbumsSaved(mbid: String, completion: @escaping (Bool, Error?) -> ()) {
        let isSaved = getAlbumById(mbid: mbid).count == 0 ? false : true
        completion(isSaved, nil)
    }
    
    func deleteAlbum(mbid: String, completion: @escaping () -> ()) {
        let albums = getAlbumById(mbid: mbid)
        for album in albums {
            for track in album.tracks {
                try! realm.write {
                    realm.delete(track)
                }
            }
            do {
                try realm.write {
                    realm.delete(album)
                }
            } catch {
                // fatalErrors will be replaced with proper error handling
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func getAlbumDetail(albumId mbid: String, completion: @escaping (AlbumDetailModel?, Error?) -> ()) {
        if getAlbumById(mbid: mbid).count == 0 {
            completion(nil,nil)
        } else {
            guard let album = getAlbumById(mbid: mbid).first else { return  }
            let albumDetailModel = AlbumDetailModel(realmAlbum: album)
            completion(albumDetailModel, nil)
        }
    }
    
    private func getAlbumById(mbid: String) -> [RealmAlbumModel] {
        let albums = realm.objects(RealmAlbumModel.self).filter("mbid = '\(mbid)'")
        if albums.count > 0 {
            return Array(albums)
        }
        
        return []
    }
}

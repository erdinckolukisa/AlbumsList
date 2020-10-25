//
//  CoreDataStorage.swift

import UIKit
import CoreData
import AlamofireImage
class CoreDataStorage: Persistable {
    
    let downloader = ImageDownloader()
    let context: NSManagedObjectContext
    
    // default behaviour is used for application and isForTesting == true is used for unit tests
    init(isForTesting: Bool = false) {
        if isForTesting == false {
            self.context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        } else {
            self.context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainerForTesting.viewContext
        }
    }
    
    func saveContext () {
        if self.context.hasChanges {
            do {
                try  self.context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - saveAlbum
    func saveAlbum(album: AlbumDetailModel, completion: @escaping (Error?) -> ()) {
        if getAlbumById(mbid: album.mbid).count > 0 {
            // - albums must be unique
            completion(nil)
            return
        }
        let error = NSError(domain:"", code: -1, userInfo:[NSLocalizedDescriptionKey: "An error occured. Plase try again later.".localizedString])
        let albumEntity = AlbumEntity(context: self.context)
        albumEntity.mbid = album.mbid
        albumEntity.name = album.albumName
        albumEntity.artistName = album.artistName
        albumEntity.albumDescription = album.wikiSummary
        albumEntity.createdAt = Date() as NSDate
        
        album.albumTracks?.forEach({ track in
            let trackEntity = TracksEntity(context: self.context)
            trackEntity.artistName = track.artistName
            trackEntity.trackName = track.name
            trackEntity.duration = track.duration
            trackEntity.album = albumEntity
        })
        
        guard let url = URL(string: album.images?.last?.url ?? "") else {
            saveContext()
            completion(error)
            return
        }
        let urlRequest = URLRequest(url: url)
        self.downloader.download(urlRequest) { [weak self] response in
            if let imageData = response.data {
                albumEntity.albumImage = imageData as NSData
            }
            self?.saveContext()
            completion(nil)
        }
    }
    
    // MARK: - getAllAlbums
    func getAllAlbums(completion: @escaping ([LocalAlbumModel]?, Error?) -> ()) {
        let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(AlbumEntity.createdAt), ascending: false)
        request.sortDescriptors = [sort]
        do {
            let albums = try self.context.fetch(request)
            
            
            let albumModels = albums.compactMap { LocalAlbumModel(mbid: $0.mbid, albumName: $0.name ?? "", imageData: $0.albumImage as Data?) }
            completion(albumModels, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    // MARK: - isAlbumSaveds
    func isAlbumsSaved(mbid: String, completion: @escaping (Bool, Error?) -> ()) {
        let isSaved = getAlbumById(mbid: mbid).count == 0 ? false : true
        completion(isSaved, nil)
    }
    
    private func getAlbumById(mbid: String) -> [AlbumEntity] {
        let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
        let predicate = NSPredicate(format: "mbid == [cd] %@", mbid)
        request.predicate = predicate
        do {
            let album = try self.context.fetch(request)
            return album
        } catch {
            return []
        }
    }
    
    // MARK: - getAlbumDetail
    func getAlbumDetail(albumId mbid: String, completion: @escaping (AlbumDetailModel?, Error?) -> ()) {
        if getAlbumById(mbid: mbid).count == 0 {
            // TODO: - add custom error
            completion(nil,nil)
        } else {
            guard let albumEntity = getAlbumById(mbid: mbid).first else { return  }
            let albumDetailModel = AlbumDetailModel(albumEntity: albumEntity)
            completion(albumDetailModel, nil)
        }
        
    }
    
    // MARK: - deleteAlbum
    func deleteAlbum(mbid: String, completion: @escaping () -> ()) {
        let albums = getAlbumById(mbid: mbid)
        for album in albums {
            context.delete(album)
        }
        self.saveContext()
        completion()
    }
}

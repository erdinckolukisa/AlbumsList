//
//  AlbumDetailViewModel.swift

import Foundation
import AlamofireImage
protocol AlbumDetailProtocol: class {
    func albumDetailDidUpdate()
    func albumDetailImageDidUpdate(imageData: Data)
    func albumDetailErrorDidUpdate(error: Error?)
    func isAlbumSavedLocally(isSaved: Bool, error: Error?)
}

class AlbumDetailViewModel {
    private var mbid: String?
    private var networking: Networkable
    private var persistable: Persistable
    private var workFromPerisitantStorage: Bool
    private var albumDetailModel: AlbumDetailModel?
    weak var deletegate: AlbumDetailProtocol!
    private let downloader = ImageDownloader()
    var albumName: String
    var artistName: String
    var imageUrl: String
    var wikiSummary: String
    var wikiContent: String
    var numberOfTracks: Int {
        return tracks.count
    }
    
    var tracks = [TrackViewModel]()
    init(networking: Networkable, persistable: Persistable, workFromPersistantStorage: Bool) {
        self.networking = networking
        self.persistable = persistable
        self.workFromPerisitantStorage = workFromPersistantStorage
        albumName = ""
        artistName = ""
        imageUrl = ""
        wikiSummary = ""
        wikiContent = ""
    }
    
    func getAlbumDetail(mbid: String) {
        if workFromPerisitantStorage == true {
            getAlbumWithPersistable(mbid: mbid)
        } else {
            geAlbumWithNetworking(mbid: mbid)
        }
    }
    
    // MARK: - GetAlbumWithPersistable
    func getAlbumWithPersistable(mbid: String) {
        persistable.getAlbumDetail(albumId: mbid) { [weak self] albumDetailModel, error in
            if error != nil {
                let customError = CustomErrorCreator.createDefaulError()
                self?.deletegate.albumDetailErrorDidUpdate(error: customError)
                return
            }
            guard let self = self else { return }
            self.setViewModelValuesBasedOnAlbumDetailModel(albumDetailModel: albumDetailModel)
        }
    }
    
    // MARK: - GeAlbumWithNetworking
    func geAlbumWithNetworking(mbid: String) {
        networking.getAlbumDetail(albumId: mbid) { [weak self] albumDetailModel, error in
            if error != nil {
                self?.deletegate.albumDetailErrorDidUpdate(error: error)
                return
            }
            guard let self = self else { return }
            self.setViewModelValuesBasedOnAlbumDetailModel(albumDetailModel: albumDetailModel)
        }
    }
    
    private func setViewModelValuesBasedOnAlbumDetailModel(albumDetailModel: AlbumDetailModel?) {
        guard let albumDetailModel = albumDetailModel else { self.refreshSaveRemoveButtonState(); return }
        self.mbid = albumDetailModel.mbid
        self.albumName = albumDetailModel.albumName ?? "unknown"
        self.artistName = albumDetailModel.artistName ?? "unknown"
        self.imageUrl = albumDetailModel.images?.last?.url ?? ""
        self.wikiSummary = albumDetailModel.wikiSummary ?? ""
        self.wikiContent = albumDetailModel.wikiContent ?? ""
        self.tracks = albumDetailModel.albumTracks?.compactMap { TrackViewModel(trackName: $0.name, artistName: $0.artistName, trackDuration: $0.duration)} ?? []
        self.deletegate.albumDetailDidUpdate()
        self.getAlbumPhotoData(uri: albumDetailModel.images?.last?.url ?? "")
        self.albumDetailModel = albumDetailModel
        if let imageData = albumDetailModel.imageData {
            self.deletegate.albumDetailImageDidUpdate(imageData: imageData)
        }
        self.refreshSaveRemoveButtonState()
    }
    
    private func refreshSaveRemoveButtonState() {
        if let mbid = mbid {
            self.persistable.isAlbumsSaved(mbid: mbid, completion: { [weak self] isSaved, error in
                self?.deletegate.isAlbumSavedLocally(isSaved: isSaved, error: error)
            })
        } else {
            let error = NSError(domain:"", code: -1, userInfo:[NSLocalizedDescriptionKey: "An error occured. Plase try again later.".localizedString])
            self.deletegate.isAlbumSavedLocally(isSaved: false, error: error)
        }
    }
    
    // MARK: - SaveOrRemoveAlbum
    func saveOrRemoveAlbum() {
        guard let mbid = self.mbid else  { return }
        self.persistable.isAlbumsSaved(mbid: mbid, completion: { [weak self] isSaved, error in
            if error != nil {
                self?.deletegate.albumDetailErrorDidUpdate(error: error)
                return
            }
            if isSaved == false {
                if let detail = self?.albumDetailModel {
                    self?.persistable.saveAlbum(album: detail, completion: { error in
                        self?.refreshSaveRemoveButtonState()
                    })
                }
            } else {
                self?.persistable.deleteAlbum(mbid: mbid, completion: {
                    self?.refreshSaveRemoveButtonState()
                })
            }
        })
    }
    
    // MARK: - GetAlbumPhotoData
    func getAlbumPhotoData(uri: String) {
        guard let url = URL(string: uri) else { return }
        let urlRequest = URLRequest(url: url)
        downloader.download(urlRequest) { [weak self] response in
            if let imageData = response.data {
                self?.deletegate.albumDetailImageDidUpdate(imageData: imageData)
            }
        }
    }
}

//
//  MainViewModel.swift

import Foundation

protocol LocalAlbumsViewModelProtocol: class {
    func localAlbumsDidUpdate()
    func localAblumsErrorDidUpdate(error: Error?)
}

class LocalAlbumsViewModel {
    var persistable: Persistable
    var albums = [LocalAlbumCellViewModel]()
    weak var delegate: LocalAlbumsViewModelProtocol?
    init(persistable: Persistable) {
        self.persistable = persistable
    }
    
    func getAlbums() {
        persistable.getAllAlbums { [weak self] mainViewLocalAlbumModels, error in
            self?.albums = mainViewLocalAlbumModels?.compactMap { LocalAlbumCellViewModel(album: $0)} ?? []
            self?.delegate?.localAlbumsDidUpdate()
        }
    }
}

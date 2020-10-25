//
//  ArtistsViewModel.swift

import Foundation

protocol ArtistsViewModelProtocol: class {
    func artistsDidUpdate()
    func errorDidUpdate(error: Error?)
}

class ArtistsViewModel {
    var networking: Networkable
    weak var delegate: ArtistsViewModelProtocol?
    var artists = [ArtistsCellViewModel]()
    var workItem: DispatchWorkItem?
    
    init(networking: Networkable) {
        self.networking = networking
    }
    
    func searchArtist(name: String?) {
        // - DispatchWorkItem is used to prevent request for each key press, instead it waits the user (1sec) in order to search
        guard let name = name, name.count > 0 else {
            artists.removeAll()
            self.delegate?.artistsDidUpdate()
            return
        }
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            if (self?.workItem!.isCancelled)! {
                return
            }
            
            self?.networking.searchArtists(searchText: name) { [weak self] result, error in
                if error != nil {
                    self?.delegate?.errorDidUpdate(error: error)
                }
                if let matchedArtists = result?.objects?.artist {
                    self?.artists = matchedArtists.compactMap { ArtistsCellViewModel(mbid: $0.mbid, artistName: $0.name, artistPhotoURL: $0.image?.first?.url)}
                    self?.delegate?.artistsDidUpdate()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem!)
    }
}

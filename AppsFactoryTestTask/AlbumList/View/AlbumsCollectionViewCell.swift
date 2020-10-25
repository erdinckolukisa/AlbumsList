//
//  AlbumCollectionViewCell.swift

import UIKit

class AlbumsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    
    func configure(albumsCellViewModel: AlbumsCellViewModel) {
        self.albumName.text = albumsCellViewModel.albumName
        if let url = URL(string: albumsCellViewModel.imageUrlString ?? "") {
            self.albumImage.af_setImage(withURL: url)
        }
    }
    
    func configureWithLocalData(localAlbumCellViewModel: LocalAlbumCellViewModel) {
        self.albumName.text = localAlbumCellViewModel.albumName
        if let imageData = localAlbumCellViewModel.imageData {
            self.albumImage.image = UIImage(data: imageData)
        } else {
            self.albumImage.image = UIImage(named: "placeholder")
        }
        
    }
}

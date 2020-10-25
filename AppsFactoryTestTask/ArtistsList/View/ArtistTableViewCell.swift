//
//  ArtistTableViewCell.swift

import UIKit
import AlamofireImage
class ArtistTableViewCell: UITableViewCell {
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(artistCellViewModel: ArtistsCellViewModel) {
        self.artistName.text = artistCellViewModel.artistName
        if let url = URL(string: artistCellViewModel.artistPhotoURL ?? "") {
            self.artistPhoto.af_setImage(withURL: url)
        }
    }
}

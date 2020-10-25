//
//  TrackTableViewCell.swift

import UIKit

class TrackTableViewCell: UITableViewCell {
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(trackViewModel: TrackViewModel) {
        trackName.text = trackViewModel.trackName
        artistName.text = trackViewModel.artistName
        duration.text = trackViewModel.trackDuration
    }
}

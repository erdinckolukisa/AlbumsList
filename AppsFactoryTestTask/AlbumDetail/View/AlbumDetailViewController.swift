//
//  AlbumDetailViewController.swift

import UIKit

enum SaveRemoveButtonState {
    case save
    case delete
}

class AlbumDetailViewController: UIViewController {
    var mbid: String?
    var workFromPersistantStorage: Bool = false
    var albumDetailViewModel: AlbumDetailViewModel!
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var numberOfTracks: UILabel!
    @IBOutlet weak var albumDescription: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var albumDesctiptionTextFielHeightConstraint: NSLayoutConstraint!
    var saveRemoveButtonState: SaveRemoveButtonState = .save
    // - Description textViews height can be at max 200 if it exceeds that height, it become scrollable
    let maxTextFieldHeight:CGFloat = 200
    let minTextFieldHeight:CGFloat = 10
    @IBOutlet weak var saveOrRemoveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSaveRemoveButton()
        bind()
        self.title = "Album Details".localizedString
        
    }
    
    func configureSaveRemoveButton() {
        saveOrRemoveButton.target = self
        saveOrRemoveButton.action =  #selector(saveOrRemove(sender:))
        saveOrRemoveButton.isEnabled = false
    }
    
    @objc func saveOrRemove(sender: UIBarButtonItem) {
        if saveRemoveButtonState == .delete {
            let alert = UIAlertController(title: "Delete Album", message: "Do you want to delete the local album", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.saveOrRemoveButton.isEnabled = false
                self.albumDetailViewModel.saveOrRemoveAlbum()
                self.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            self.albumDetailViewModel.saveOrRemoveAlbum()
            saveOrRemoveButton.isEnabled = false
        }
    }
    
    func bind() {
        guard let albumId = mbid else { return }
        // - StubApi() can be injected instead of WebApi() without changing anything else in the code
        albumDetailViewModel = AlbumDetailViewModel(networking: WebApi(), persistable: RealmStorage(),workFromPersistantStorage: workFromPersistantStorage)
        albumDetailViewModel.deletegate = self
        albumDetailViewModel.getAlbumDetail(mbid: albumId)
    }
    
    func resizeTextViewInOrderToFitText() {
        let size = CGSize(width: albumDescription.frame.width, height: .infinity)
        let expectedSize = albumDescription.sizeThatFits(size)
        self.albumDesctiptionTextFielHeightConstraint.constant = max(min(expectedSize.height, self.maxTextFieldHeight), self.minTextFieldHeight)
        self.albumDescription.isScrollEnabled = expectedSize.height > self.maxTextFieldHeight
    }
}

extension AlbumDetailViewController: AlbumDetailProtocol {
    func isAlbumSavedLocally(isSaved: Bool, error: Error?) {
        if error == nil {
            saveOrRemoveButton.isEnabled = true
            if isSaved == true {
                saveOrRemoveButton.title = "delete"
                self.saveRemoveButtonState = .delete
            } else {
                saveOrRemoveButton.title = "save"
                self.saveRemoveButtonState = .save
            }
        } else {
            saveOrRemoveButton.isEnabled = false
        }
    }
    
    func albumDetailImageDidUpdate(imageData: Data) {
        self.albumImageView.image = UIImage(data: imageData)
    }
    
    func albumDetailDidUpdate() {
        albumName.text = albumDetailViewModel.albumName
        artistName.text = albumDetailViewModel.artistName
        numberOfTracks.text = "\(albumDetailViewModel.numberOfTracks) tracks"
        albumDescription.text = albumDetailViewModel.wikiSummary.htmlToAttributedString?.string ?? ""
        resizeTextViewInOrderToFitText()
        tableView.reloadData()
    }
    
    func albumDetailErrorDidUpdate(error: Error?) {
        showCustomMessageAlert(message: error?.localizedDescription ?? "") {
            
        }
    }
}

extension AlbumDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumDetailViewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ConstantValues.trackCellIdentifier, for: indexPath) as? TrackTableViewCell {
            cell.configure(trackViewModel: albumDetailViewModel.tracks[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

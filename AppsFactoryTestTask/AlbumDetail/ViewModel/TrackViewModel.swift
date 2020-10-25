//
//  TrackViewModel.swift

import Foundation

class TrackViewModel {
    var trackName: String
    var artistName: String
    private var trackDurationRaw: String
    var trackDuration: String {
        guard let trackDurationInSecIntValue = Int(trackDurationRaw) else { return "unknown"}
        let seconds = trackDurationInSecIntValue % 60
        let minutes = (trackDurationInSecIntValue / 60) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    init(trackName: String?, artistName: String?,trackDuration: String?) {
        self.trackName = trackName ?? "unknown"
        self.artistName = artistName ?? "unknown"
        self.trackDurationRaw = trackDuration ?? ""
    }
}

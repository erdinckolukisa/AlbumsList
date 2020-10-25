//
//  ImageModel.swift

import Foundation

struct ImageModel: Decodable {
    var url: String?
    var size: String?
    enum CodingKeys: String, CodingKey {
        case url = "#text"
        case size = "size"
    }
}

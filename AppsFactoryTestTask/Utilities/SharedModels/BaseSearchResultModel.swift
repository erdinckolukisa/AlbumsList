//
//  BaseSearchResult.swift

import Foundation

struct BaseSearchResultModel<T: Decodable>: Decodable {
    var totalResults: String?
    var startIndex: String?
    var itemsPerPage: String?
    var objects: T?
    
    private struct CustomCodingKey: CodingKey {
        let stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        let intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKey.self)
        let results = try container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: CustomCodingKey(stringValue: "results")!)
        totalResults = try? results.decode(String.self, forKey: CustomCodingKey(stringValue: "opensearch:totalResults")!)
        startIndex = try? results.decode(String.self, forKey: CustomCodingKey(stringValue: "opensearch:startIndex")!)
        itemsPerPage = try? results.decode(String.self, forKey: CustomCodingKey(stringValue: "opensearch:itemsPerPage")!)
        objects = try? results.decode(T.self, forKey: CustomCodingKey(stringValue: String(describing: T.self).lowercased())!)
    }
}

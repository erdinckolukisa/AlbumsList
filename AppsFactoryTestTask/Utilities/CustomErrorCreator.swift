//
//  CustomErrorCreator.swift

import Foundation


struct CustomError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
struct CustomErrorCreator {
    static func createError(customErrorModel: CustomErrorModel) -> Error {
        return CustomError(customErrorModel.message ?? "An error occured. Plase try again later.".localizedString)
    }
    
    static func createError(errorMessage: String) -> Error {
        return CustomError(errorMessage)
    }
    
    static func createDefaulError() -> Error {
        return CustomError("An error occured. Plase try again later.".localizedString)
    }
}

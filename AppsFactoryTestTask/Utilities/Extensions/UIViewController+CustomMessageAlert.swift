//
//  UIViewController+CustomMessageAlert.swift

import UIKit

extension UIViewController {
    func showCustomMessageAlert(message: String, title: String = "", completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localizedString, style: .default) { _ in
            completion()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

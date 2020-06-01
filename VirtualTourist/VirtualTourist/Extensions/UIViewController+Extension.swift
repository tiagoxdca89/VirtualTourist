//
//  UIViewController+Extension.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 01/06/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    func showLoading(show: Bool) {
        if show {
            MBProgressHUD.showAdded(to: view, animated: true)
        } else {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

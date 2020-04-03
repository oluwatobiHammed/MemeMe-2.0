//
//   MemeEditorViewController+extension.swift
//  MemeMe
//
//  Created by user on 03/04/2020.
//  Copyright © 2020 Anastasia Petrova. All rights reserved.
//

import Foundation
import UIKit

extension MemeEditorViewController: UINavigationControllerDelegate {}

extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIView {
    class func animationOptions(for curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        switch curve {
        case .easeInOut: return .curveEaseInOut
        case .easeIn: return .curveEaseIn
        case .easeOut: return .curveEaseOut
        case .linear: return .curveLinear
        @unknown default: return .curveLinear
        }
    }
}


//
//  PhotoLibraryBrowser.swift
//  Meme
//
//  Created by Oladipupo Oluwatobi on 29/03/2020.
//  Copyright © 2020 Oladipupo Oluwatobi. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import UIKit

extension UIImagePickerController {
    convenience init?(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return nil
        }
        self.init()
        self.sourceType = sourceType
        self.mediaTypes = [kUTTypeImage as String]
    }
}

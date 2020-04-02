//
//  ImageStore.swift
//  Meme
//
//  Created by Oladipupo Oluwatobi on 29/03/2020.
//  Copyright © 2020 Oladipupo Oluwatobi. All rights reserved.
//

import Foundation
import UIKit

enum ImageStore {
    static let memeImagesDirectoryName = "memeImages"
    
    public static let memeImagesDirectoryURL: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(memeImagesDirectoryName)
    
    public static func saveImage(image: UIImage, id: UUID) throws {
        guard let imageData = image.pngData() else {
            throw ImageStore.Error.imageNotFound
        }
        if !FileManager.default.fileExists(atPath: memeImagesDirectoryURL.path) {
            try FileManager.default.createDirectory(
                at: memeImagesDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        let fileURL = memeImagesDirectoryURL.appendingPathComponent(id.uuidString)
        try imageData.write(to: fileURL, options: .atomic)
    }
    
    static func deleteImage(id: UUID) throws -> Void {
        let url = memeImagesDirectoryURL.appendingPathComponent(id.uuidString)
        try FileManager.default.removeItem(at: url)
    }
    
    static func getImage(id: UUID) -> UIImage? {
        let url = memeImagesDirectoryURL.appendingPathComponent(id.uuidString)
        return UIImage(contentsOfFile: url.path)
    }
}

extension ImageStore {
    enum `Error`: Swift.Error {
        case imageNotFound
        
        var title: String {
            switch self {
            case .imageNotFound:
                return Labels.ImageStorage.Error.imageNotFoundTitle
            }
        }
        
        var localizedDescription: String {
            switch self {
            case .imageNotFound:
                return Labels.ImageStorage.Error.imageNotFoundDescription
            }
        }
    }
}

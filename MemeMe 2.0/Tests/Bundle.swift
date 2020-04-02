//
//  TesrBundle.swift
//  MemeTests
//
//  Created by Oladipupo Oluwatobi on 29/03/2020.
//  Copyright © 2020 Oladipupo Oluwatobi. All rights reserved.
//

import Foundation

extension Bundle {
    static let unitTests = Bundle(for: BundleLocator.self)
}

private class BundleLocator {}

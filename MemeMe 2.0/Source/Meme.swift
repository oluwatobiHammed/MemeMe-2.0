//
//  Meme.swift
//  Meme
//
//  Created by Oladipupo Oluwatobi on 29/03/2020.
//  Copyright © 2020 Oladipupo Oluwatobi. All rights reserved.
//

import UIKit

struct Meme: Codable {
    let id: UUID
    var topText: String
    var bottomText: String
    let date: Date
}

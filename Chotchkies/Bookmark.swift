//
//  Bookmark.swift
//  Chotchkies
//
//  Created by Mark Calvo-Cruz on 9/29/18.
//  Copyright © 2018 hello U. All rights reserved.
//

import Foundation

struct Bookmark: Codable {
    var article: Article
    var saved: Date
    var hidden: Bool = false
    
    init(article: Article) {
        self.article = article
        self.saved = Date()
    }
}

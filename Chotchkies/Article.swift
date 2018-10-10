//
//  Article.swift
//  Chotchkies
//
//  Created by Mark Calvo-Cruz on 9/29/18.
//  Copyright © 2018 hello U. All rights reserved.
//

import Foundation
struct Article: Codable {
    var url: String
    var description: String
    var image: String?
    
    var domain: String?
    var author: String = ""
    var date: Date?
    
    init(description: String, xml: String, pubDate: Date?) {
        //print(xml)
        self.url = xml.slice(from: "\"", to: "\"")!
        self.description = description.substringToFirstChar(of: "(")
        if let meta = description.slice(from: "(", to: ")") {
            let array: [String] = meta.components(separatedBy: "/")
            if array.count == 1 {
                self.domain = array[0]
            } else if array.count > 1 {
                self.author = array[0]
                self.domain = array[1]
                self.date = pubDate
                // print(array)
            }
        } else {
            print("Error parsing: \(description)")
        }
        
    }
    
    
}

extension String {
    func slice(from: String, to: String, options: NSString.CompareOptions = []) -> String? {
        return  (range(of: from, options: options)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
    func substringToFirstChar(of char: Character) -> String
    {
        guard let pos = self.range(of: String(char)) else { return self }
        // or  guard let pos = self.index(of: char) else { return self }
        let subString = self[..<pos.lowerBound]
        return String(subString)
    }
    
}

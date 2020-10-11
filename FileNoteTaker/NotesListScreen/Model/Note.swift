//
//  Note.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/10/20.
//

import Foundation

enum FileType: String, Decodable {
    
    case txt = "txt"
    case xml = "xml"
    case json = "json"
    case plist = "plist"
}

struct Note: Decodable {
    
    var title: String
    var details: String
    var type: FileType
    var path: String
    
    enum CodingKeys: String, CodingKey {
        
        case title
        case details
        case type
        case path
    }
}

//
//  String+Ext.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/11/20.
//

import Foundation

extension String {
    
    func fileName() -> String {
        
        let arrayOfPath = self.split(separator: "/")
        guard let subString = arrayOfPath.last else { return "" }
        return String(subString)
    }
}

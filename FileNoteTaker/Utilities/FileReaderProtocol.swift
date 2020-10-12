//
//  FileReaderProtocol.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/11/20.
//

import Foundation

protocol FileReaderProtocol { }

extension FileReaderProtocol {
    
    func loadDataFromTextFile(with path: URL) -> Note? {
        
        do {
            let dataContent = try String(contentsOf: path, encoding: .utf8)
            return self.parseTextFileResults(of: dataContent, with: path.absoluteString)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func loadDataFromTextFile(with path: String) -> Note? {
        
        do {
            let dataContent = try String(contentsOfFile: path, encoding: .utf8)
            return self.parseTextFileResults(of: dataContent, with: path)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func parseTextFileResults(of text: String, with path: String) -> Note? {
        
        let tempArr = text.components(separatedBy: "\n")
        var title = ""
        var details = ""
        
        if tempArr.count > 0 {
            title = tempArr[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if tempArr.count > 1 {
                details = tempArr[1...].joined(separator: "\n")
            }
            return Note(title: title, details: details, type: .txt, path: path)
        }
        return nil
    }
}

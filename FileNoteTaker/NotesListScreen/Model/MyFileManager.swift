//
//  FileManager.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/11/20.
//

import UIKit

class MyFileManager {
    
    // MARK: - Variables
    
    static let shared = MyFileManager()
    
    private let manager = FileManager.default
    private let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // MARK: - Init
    
    private init() { }
    
    // MARK: - Copy
    
    func copyFile(note: Note) {
        
        if note.type == .txt {
            guard let oldPath = Bundle.main.path(forResource: "Note", ofType: note.type.rawValue) else { return }
            let oldUrl = URL(fileURLWithPath: oldPath)
            
            do {
                let newPath = paths[0].appendingPathComponent(note.path.fileName())
                try manager.copyItem(at: oldUrl, to: newPath)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Load from Directories
    
    func getDeleteSoonFiles() -> [URL]? {
        
        let deletePath = paths[0].appendingPathComponent("SoonToDeleteFolder")
        
        do {
            let fileURLs = try manager.contentsOfDirectory(at: deletePath, includingPropertiesForKeys: nil)
            return fileURLs
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func getDirectoryFiles() -> [URL]? {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            return try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    // MARK: - Load from Resources folder
    
    func getPlistFile<T: Decodable>(withName name: String) -> T? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let data = FileManager.default.contents(atPath: path) else { return nil }
        do {
            let obj = try PropertyListDecoder().decode(T.self, from: data)
            return obj
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func getJSONFile<T: Decodable>(withName name: String) -> T? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else { return nil }
        do {
            let data = try NSData(contentsOfFile: path, options: .mappedIfSafe) as Data
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func getBundleTxtPath() -> String? {
        return  Bundle.main.path(forResource: "Note", ofType: "txt")
    }
    
    // MARK: - Create
    
    func createFile() -> (data: String, path: String)? {
        
        let uid = UUID()
        let url = paths[0].appendingPathComponent("\(uid).txt")
        let str = "New Note"
        
        do {
            try str.write(to: url, atomically: true, encoding: .utf8)
            let data = try String(contentsOf: url, encoding: .utf8)
            return (data: data, path: url.absoluteString)
        } catch {
            print(error)
            return nil
        }
    }
    
    func createNewNote(with data: Note) {
        
        let uid = UUID()
        let url = paths[0].appendingPathComponent("Note.\(uid).txt")
        let str = "\(data.title)\n\(data.details)"
        
        do {
            try str.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Write
    
    func writeFile(with data: String, note: Note) {
        
        let url = paths[0].appendingPathComponent(note.path.fileName())
        do {
            try data.write(to: url, atomically: true, encoding: .utf8)
            let data = try String(contentsOf: url, encoding: .utf8)
            print(data.description)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Move
    
    func moveFile(note: Note) -> Bool {
        
        let url = paths[0].appendingPathComponent(note.path.fileName())
        let dataPath = paths[0].appendingPathComponent("SoonToDeleteFolder")
        
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        do {
            let newPath = dataPath.appendingPathComponent(note.path.fileName())
            try manager.moveItem(at: url, to: newPath)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Delete
    
    func deleteFile(note: Note) -> Bool {
        
        let url = paths[0].appendingPathComponent("SoonToDeleteFolder/\(note.path.fileName())")
        
        do {
            try manager.removeItem(at: url)
            return true
        } catch {
            print(error)
            return false
        }
    }
}

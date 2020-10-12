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
    
    private let fm = FileManager.default
    private let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // MARK: - Init
    
    private init() { }
    
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
    
    // MARK: - Load Files in DeleteSoon
    
    func getDeleteSoonFiles() -> [URL]? {
        
        let deletePath = paths[0].appendingPathComponent("SoonToDelete")
        
        do {
            let fileURLs = try fm.contentsOfDirectory(at: deletePath, includingPropertiesForKeys: nil)
            return fileURLs
        } catch let error {
            print(error)
            return nil
        }
    }
    
    // MARK: - Delete
    
    func deleteFile(note: Note) -> Bool {
        
        let url = paths[0].appendingPathComponent(note.path.fileName())
        
        do {
            try fm.removeItem(at: url)
            return true
        } catch {
            print(error)
            return false
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
            try fm.moveItem(at: url, to: newPath)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Copy
    
    func copyFile(note: Note) {
        
        guard let oldPath = Bundle.main.path(forResource: "Note", ofType: note.type.rawValue),
              let oldUrl = URL(string: oldPath) else { return }
        
        do {
            let newPath = paths[0].appendingPathComponent(note.path.fileName())
            try fm.copyItem(at: oldUrl, to: newPath)
        } catch {
            print(error)
        }
    }
}

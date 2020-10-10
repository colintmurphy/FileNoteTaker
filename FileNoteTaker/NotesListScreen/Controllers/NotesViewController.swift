//
//  NotesViewController.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/10/20.
//

import UIKit

class NotesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    
    private var notes: [Note] = []
    private var xmlElement: String = ""
    private var xmlTitle: String = ""
    private var xmlDetails: String = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.loadDataFromPlist()
        self.loadDataFromTextFile()
        self.loadDataFromJSONFile()
        self.loadDataFromXMLFile(withName: "Note")
        
        self.tableView.register(UINib(nibName: NoteTableViewCell.reuseId, bundle: nil), forCellReuseIdentifier: NoteTableViewCell.reuseId)
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - IBActions
    
    @IBAction func createNewNote(_ sender: Any) {
        
    }
    
    // MARK: - Handle .plist File
    
    private func loadDataFromPlist() {
        
        guard let note: Note = self.getPlistFile(withName: "Note") else { return }
        self.notes.append(note)
    }
    
    private func getPlistFile<T: Decodable>(withName name: String) -> T? {
        
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
    
    // MARK: - Handle .json File
    
    private func loadDataFromJSONFile() {
        
        guard let note: Note = self.getJSONFile(withName: "Note") else { return }
        self.notes.append(note)
    }
    
    private func getJSONFile<T: Decodable>(withName name: String) -> T? {
        
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
    
    // MARK: - Handle .txt File
    
    private func loadDataFromTextFile() {
        
        guard let note: String = self.getTextFile(withName: "Note") else { return }
        self.parseTextFileResults(of: note)
    }
    
    private func getTextFile(withName name: String) -> String? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "txt") else { return nil }
        do {
            let dataContent = try String(contentsOfFile: path, encoding: .utf8)
            return dataContent
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func parseTextFileResults(of text: String) {
        
        let tempArr = text.components(separatedBy: "\n")
        if tempArr.count > 1 {
            let title = tempArr[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let details: String = tempArr[1...].joined(separator: "\n")
            let newNote = Note(title: title, details: details, type: .txt)
            self.notes.append(newNote)
        }
    }
    
    // MARK: - Handle .xml File
    
    private func loadDataFromXMLFile(withName name: String) {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "xml") else { return }
        if let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) {
            parser.delegate = self
            parser.parse()
        }
    }
}

// MARK: - XMLParserDelegate

extension NotesViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        
        if elementName == "note" {
            self.xmlTitle = ""
            self.xmlDetails = ""
        }
        self.xmlElement = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "note" {
            let newNote = Note(title: self.xmlTitle, details: self.xmlDetails, type: .xml)
            self.notes.append(newNote)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if self.xmlElement == "title" {
            self.xmlTitle += data
        } else if self.xmlElement == "details" {
            self.xmlDetails += data
        }
    }
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let story = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = story.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController {
            editVC.note = self.notes[indexPath.row]
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseId, for: indexPath) as? NoteTableViewCell else { fatalError("couldn't create NoteTableViewCell") }
        
        cell.set(title: self.notes[indexPath.row].title, details: self.notes[indexPath.row].details)
        
        return cell
    }
}

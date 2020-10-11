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
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - IBActions
    
    @IBAction func createNewNote(_ sender: Any) {
        
        // MARK: - CREATE

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("message3.txt")
        let str = "Test Message 3"
        
        do {
            try str.write(to: url, atomically: true, encoding: .utf8)
            let data = try String(contentsOf: url, encoding: .utf8)
            self.parseTextFileResults(of: data)
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteNote(at note: Note) -> Bool {
        
        // MARK: - DELETE
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("message2.txt")
        print(paths[0])
        
        /*
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print(error)
            return false
        }*/
        
        // MARK: - MOVE
        
        let dataPath = paths[0].appendingPathComponent("SoonToDeleteFolder")
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
        do {
            try FileManager.default.moveItem(at: url, to: dataPath.appendingPathComponent("message2.txt"))
            return true
        } catch {
            print(error)
            return false
        }
        
        /*
        do {
            try FileManager.default.copyItem(at: <#T##URL#>, to: <#T##URL#>)
            return true
        } catch {
            print(error)
            return false
        }*/
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
            let newNote = Note(title: title, details: details, type: .txt, path: "Resources/Note.txt")
            self.notes.append(newNote)
        } else if tempArr.count == 1 {
            let title = tempArr[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let newNote = Note(title: title, details: "", type: .txt, path: "Resources/Note.txt")
            self.notes.append(newNote)
        }
    }
    
    private func readDocsFromDirectory() {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for url in fileURLs {
                let data = try String(contentsOf: url, encoding: .utf8)
                self.parseTextFileResults(of: data)
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
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
    
    // MARK: - Setup
    
    private func setup() {
        
        self.loadDataFromPlist()
        self.loadDataFromTextFile()
        self.loadDataFromJSONFile()
        self.loadDataFromXMLFile(withName: "Note")
        readDocsFromDirectory()
        
        self.tableView.register(UINib(nibName: NoteTableViewCell.reuseId, bundle: nil), forCellReuseIdentifier: NoteTableViewCell.reuseId)
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
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
            let newNote = Note(title: self.xmlTitle, details: self.xmlDetails, type: .xml, path: "Resources/Note.xml")
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, closure) in
            
            if self.deleteNote(at: self.notes[indexPath.row]) {
                self.notes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                print("didn't move file")
            }
        })
        
        let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
}

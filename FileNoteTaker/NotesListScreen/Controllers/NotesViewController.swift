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
    private var xmlNote: Note?
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

        if let newFile = MyFileManager.shared.createFile() {
            self.parseTextFileResults(of: newFile.data, with: newFile.path)
            self.tableView.reloadData()
        }
    }
    
    private func deleteNote(at note: Note) -> Bool {
        return MyFileManager.shared.moveFile(note: note)
    }
    
    // MARK: - Handle .txt File
    
    private func loadDataFromDirectory() {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var doInitialLoad = true
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for url in fileURLs {
                print("url: ", url)
                self.loadDataFromTextFile(with: url)
                if url.absoluteString.fileName().contains("Note.") {
                    doInitialLoad = false
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        if doInitialLoad {
            if let txtBundlePath = Bundle.main.path(forResource: "Note", ofType: "txt") {
                self.loadDataFromTextFile(with: txtBundlePath)
            }
            self.loadDataFromPlist()
            self.loadDataFromJSONFile()
            self.loadDataFromXMLFile(withName: "Note")
        }
    }
    
    // MARK: Load from Txt
    private func loadDataFromTextFile(with path: String) {
        
        do {
            let dataContent = try String(contentsOfFile: path, encoding: .utf8)
            self.parseTextFileResults(of: dataContent, with: path)
        } catch let error {
            print(error)
        }
    }
    
    private func loadDataFromTextFile(with url: URL) {
        
        do {
            let dataContent = try String(contentsOf: url, encoding: .utf8)
            self.parseTextFileResults(of: dataContent, with: url.absoluteString)
        } catch let error {
            print(error)
        }
    }
    
    // MARK: Parse
    private func parseTextFileResults(of text: String, with path: String) {
        
        let tempArr = text.components(separatedBy: "\n")
        var title = ""
        var details = ""
        
        if tempArr.count > 0 {
            title = tempArr[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if tempArr.count > 1 {
                details = tempArr[1...].joined(separator: "\n")
            }
            let newNote = Note(title: title, details: details, type: .txt, path: path)
            self.notes.append(newNote)
        }
    }
    
    // MARK: - Handle .plist File
    
    private func loadDataFromPlist() {
        
        guard let note: Note = self.getPlistFile(withName: "Note") else { return }
        #warning("this is where I should copy THIS NOT WORKING")
        MyFileManager.shared.copyFile(note: note)
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
        #warning("this is where I should copy THIS NOT WORKING")
        MyFileManager.shared.copyFile(note: note)
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
    
    // MARK: - Handle .xml File
    
    private func loadDataFromXMLFile(withName name: String) {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "xml") else { return }
        if let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) {
            parser.delegate = self
            parser.parse()
            #warning("this is where I should copy THIS NOT WORKING")
            guard let note = self.xmlNote else { return }
            MyFileManager.shared.copyFile(note: note)
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        self.loadDataFromDirectory()
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
            self.xmlNote = newNote
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
                self.showAlert(title: "Error", message: "We couldn't delete your file.")
            }
        })
        
        let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
}

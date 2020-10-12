//
//  NotesViewController.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/10/20.
//

import UIKit

class NotesViewController: UIViewController, FileReaderProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyListLabel: UILabel!
    
    // MARK: - Variables
    
    private var xmlNote: Note?
    private var xmlElement: String = ""
    private var xmlTitle: String = ""
    private var xmlDetails: String = ""
    private var selectedIndex: IndexPath?
    private var notes: [Note] = [] {
        didSet {
            self.emptyListLabel.isHidden = !self.notes.isEmpty
        }
    }
    
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
    
    @IBAction private func createNewNote(_ sender: Any) {

        if let newFile = MyFileManager.shared.createFile(),
           let note = self.parseTextFileResults(of: newFile.data, with: newFile.path) {
            
            self.notes.append(note)
            self.tableView.reloadData()
        }
    }
    
    private func deleteNote(at note: Note) -> Bool {
        return MyFileManager.shared.moveFile(note: note)
    }
    
    // MARK: - Handle .txt File
    
    private func loadDataFromDirectory() {
        
        guard let fileURLs = MyFileManager.shared.getDirectoryFiles() else { return }
        var doInitialLoad = true
        
        for url in fileURLs {
            if let note = self.loadDataFromTextFile(with: url) {
                self.notes.append(note)
            }
            if url.absoluteString.fileName().contains("Note.") {
                // files from Resources folder marked with 'Note.' at beginning
                // all other file names are marked with UUID's
                doInitialLoad = false
            }
        }
        
        if doInitialLoad {
            self.loadFromResourceFolder()
        }
    }
    
    private func loadFromResourceFolder() {
        
        if let txtBundlePath = MyFileManager.shared.getBundleTxtPath(),
            let note = self.loadDataFromTextFile(with: txtBundlePath) {
            MyFileManager.shared.copyFile(note: note)
        }
        self.loadDataFromPlist()
        self.loadDataFromJSONFile()
        self.loadDataFromXMLFile(withName: "Note")
    }
    
    // MARK: - Handle non-.txt Files
    
    private func loadDataFromPlist() {
        
        guard let note: Note = MyFileManager.shared.getPlistFile(withName: "Note") else { return }
        MyFileManager.shared.copyFile(note: note)
        MyFileManager.shared.createNewNote(with: note)
    }

    private func loadDataFromJSONFile() {
        
        guard let note: Note = MyFileManager.shared.getJSONFile(withName: "Note") else { return }
        MyFileManager.shared.copyFile(note: note)
        MyFileManager.shared.createNewNote(with: note)
    }
    
    private func loadDataFromXMLFile(withName name: String) {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "xml") else { return }
        if let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) {
            
            parser.delegate = self
            parser.parse()
            guard let note = self.xmlNote else { return }
            MyFileManager.shared.copyFile(note: note)
            MyFileManager.shared.createNewNote(with: note)
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        self.loadDataFromDirectory()
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
            
            self.selectedIndex = indexPath
            editVC.delegate = self
            editVC.note = self.notes[indexPath.row]
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
}

// MARK: - UpdateNoteDelegate

extension NotesViewController: UpdateNoteDelegate {
    
    func update(_ note: Note) {
        
        guard let index = self.selectedIndex else { return }
        self.notes[index.row] = note
        self.tableView.reloadRows(at: [index], with: .automatic)
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
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            
            if self.deleteNote(at: self.notes[indexPath.row]) {
                self.notes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                self.showAlert(title: "Error", message: "We couldn't delete your file.")
            }
        }
        
        let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
}

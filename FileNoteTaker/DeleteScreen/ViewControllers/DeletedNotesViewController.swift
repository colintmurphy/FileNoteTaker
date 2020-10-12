//
//  DeletedNotesViewController.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/10/20.
//

import UIKit

class DeletedNotesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    
    private var notes: [Note] = []
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    
    @IBAction func deleteFiles(_ sender: Any) {
        
        var presentError = false
        for note in self.notes {
            if !MyFileManager.shared.deleteFile(note: note) {
                presentError = true
            }
        }
        
        if presentError {
            self.showAlert(title: "Error", message: "We had trouble deleting one or more of your files.")
        }
    }
    
    private func deleteNote(_ note: Note) -> Bool {
        return MyFileManager.shared.deleteFile(note: note)
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        if let urls = MyFileManager.shared.getDeleteSoonFiles() {
            for url in urls {
                print("url: ", url)
                self.loadDataFromTextFile(with: url)
            }
        }
        
        self.tableView.register(UINib(nibName: NoteTableViewCell.reuseId, bundle: nil), forCellReuseIdentifier: NoteTableViewCell.reuseId)
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    
    private func loadDataFromTextFile(with path: URL) {
        
        do {
            let dataContent = try String(contentsOf: path, encoding: .utf8)
            self.parseTextFileResults(of: dataContent, with: path.absoluteString)
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
}

// MARK: - UITableViewDelegate

extension DeletedNotesViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension DeletedNotesViewController: UITableViewDataSource {
    
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
            
            if self.deleteNote(self.notes[indexPath.row]) {
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

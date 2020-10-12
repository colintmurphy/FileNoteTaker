//
//  DeletedNotesViewController.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/10/20.
//

import UIKit

class DeletedNotesViewController: UIViewController, FileReaderProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    
    private var notes: [Note] = []
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: - IBActions
    
    @IBAction func deleteFiles(_ sender: Any) {
        
        var presentError = false
        var removedIndexes: [Int] = []
        for (index, note) in self.notes.enumerated() {
            if !MyFileManager.shared.deleteFile(note: note) {
                presentError = true
            } else {
                removedIndexes.append(index)
            }
        }
        
        for index in removedIndexes.reversed() {
            self.notes.remove(at: index)
        }
        
        if presentError {
            self.showAlert(title: "Error", message: "We had trouble deleting one or more of your files.")
        } else {
            self.showAlert(title: "Yay", message: "Files successfully deleted!")
        }
        
        self.tableView.reloadData()
    }
    
    private func deleteNote(_ note: Note) -> Bool {
        return MyFileManager.shared.deleteFile(note: note)
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        self.tableView.register(UINib(nibName: NoteTableViewCell.reuseId, bundle: nil), forCellReuseIdentifier: NoteTableViewCell.reuseId)
        self.tableView.tableFooterView = UIView()
        
        guard let urls = MyFileManager.shared.getDeleteSoonFiles() else { return }
        for url in urls {
            if let note = self.loadDataFromTextFile(with: url) {
                self.notes.append(note)
            }
        }
        self.tableView.reloadData()
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

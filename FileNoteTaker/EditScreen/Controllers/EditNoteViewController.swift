//
//  EditNoteViewController.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/10/20.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Variables
    
    var note: Note?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - IBActions
    
    @IBAction func saveChanges(_ sender: Any) {
        
        guard let note = self.note,
              let text = self.textField.text else { return }
        
        // MARK: - Write to file
        
        let file = note.path
        let fileContents = text + "\n" + self.textView.text
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            do {
                try fileContents.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        self.textField.text = note?.title
        self.textView.text = note?.details
    }
}

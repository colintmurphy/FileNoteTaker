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
              let title = self.textField.text else { return }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("message2.txt")
        let strData = "\(title)\n\(self.textView.text ?? "")"
        
        do {
            try strData.write(to: url, atomically: true, encoding: .utf8)
            let data = try String(contentsOf: url, encoding: .utf8)
            print(data.description)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        self.textField.text = note?.title
        self.textView.text = note?.details
    }
}

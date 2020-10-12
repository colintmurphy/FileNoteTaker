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
        
        let strData = "\(title)\n\(self.textView.text ?? "")"
        MyFileManager.shared.writeFile(with: strData, note: note)
    }
    
    // MARK: - Keyboard handling
    
    @objc private func dismissKeyboard() {
        
        self.textView.contentInset = UIEdgeInsets(top: self.textView.contentInset.top, left: 0, bottom: 0, right: 0)
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        if self.textView.isFirstResponder {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.textView.contentInset = UIEdgeInsets(top: self.textView.contentInset.top, left: 0, bottom: keyboardSize.height, right: 0)
                
                // If textView is hidden by keyboard, scroll it so it's visible
                var aRect: CGRect = self.view.frame
                aRect.size.height -= keyboardSize.height
                
                if let textViewRect = self.textView.superview?.superview?.frame {
                    self.textView.scrollRectToVisible(textViewRect, animated: true)
                }
            }
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        self.textField.text = note?.title
        self.textView.text = note?.details
        self.textView.keyboardDismissMode = .interactive
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

//
//  EditNoteViewController.swift
//  FileNoteTaker
//
//  Created by Colin Murphy on 10/10/20.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var textField: UITextField! {
        didSet {
            self.textField.text = note?.title
        }
    }
    @IBOutlet private weak var textView: UITextView! {
        didSet {
            self.textView.text = note?.details
        }
    }
    
    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    
    var note: Note?
    weak var delegate: UpdateNoteDelegate?
    
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
    
    @IBAction private func saveChanges(_ sender: Any) {
        
        guard var note = self.note,
              let title = self.textField.text else { return }
        
        let strData = "\(title)\n\(self.textView.text ?? "")"
        MyFileManager.shared.writeFile(with: strData, note: note)
        
        note.title = title
        note.details = self.textView.text ?? ""
        self.delegate?.update(note)
    }
    
    // MARK: - Keyboard handling
    
    @objc private func dismissKeyboard() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.textViewBottomConstraint.constant = 8
        }
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo,
           let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut) {
                self.textViewBottomConstraint.constant = keyboardFrame.height + 8
            }
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        self.navigationController?.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

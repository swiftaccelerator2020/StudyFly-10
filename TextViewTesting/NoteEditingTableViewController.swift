//
//  NoteEditingTableViewController.swift
//  TextViewTesting
//
//  Created by Nicole Li on 11/12/20.
//

import UIKit

class NoteEditingTableViewController: UITableViewController, UITextViewDelegate {
    
    var note: Note!
    var newNote = false // editing
    var seletedRange: NSRange?
    var wordSelected: NSRange?
    var attributedText: NSMutableAttributedString?
    var selectedWord: String?
    var titleText: String?
    var fontSize: Int = 12
    
    @IBOutlet weak var editSizeSlider: UISlider!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentEdit: UITextView!
    @IBOutlet weak var editSizeLabel: UILabel!
    
    
    func textViewDidChange(_ textView: UITextView) {
        attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        print(attributedText as Any)
        contentEdit.attributedText = attributedText
        attributedText?.enumerateAttribute(.backgroundColor, in: NSRange(location: 0, length: textView.attributedText.length), using: { (value, range, stop) in
            if let backgroundColour = value as? UIColor {
                if backgroundColour == UIColor.yellow {
                    print(range)
                    wordSelected = range
                    if isDarkMode {
                        attributedText?.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                    }
                }
            }
        })
        editSizeSlider.isEnabled = !(attributedText?.string.isEmpty ?? true)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        print(textView.selectedRange)
        seletedRange = textView.selectedRange
    }
    
    func addCustomMenu() {
        let addDefintion = UIMenuItem(title: "Add Word Defintion", action: #selector(highlightSelectedWord))
        UIMenuController.shared.menuItems = [addDefintion]
    }
    
    private func updateColors() {
        if let attributedString = attributedText {
            attributedString.removeAttribute(.foregroundColor, range: NSRange(0..<attributedString.length))
            attributedString.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<attributedString.length))
            contentEdit.attributedText = attributedString
            if let range = wordSelected {
                if isDarkMode {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                }
            }
            contentEdit.attributedText = attributedString
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let interface = overrideUserInterfaceStyle
        if interface == .dark {
            contentEdit.textColor = UIColor.white
        }
        contentEdit.delegate = self
        editSizeSlider.value = Float(fontSize)
        addCustomMenu()
        if note == nil {
            title = "Add Note"
            contentEdit.attributedText = NSAttributedString(string: "")
            attributedText = NSMutableAttributedString(attributedString: contentEdit.attributedText)
            editSizeSlider.value = Float(12)
            editSizeLabel.text = "12"
            contentEdit.textColor = UIColor.customColor
            
        } else {
            title = "Edit Note"
            titleTextField.text = note.title
            titleText = note.title
            let attributedTextNote = note.makeNSAttributedString(string: note.content, fontSize: note.fontSize, rangeOfWord: Note.range(location: note.range?.location, length: note.range?.length))
            attributedText = NSMutableAttributedString(attributedString: attributedTextNote)
            contentEdit.attributedText = attributedTextNote
            editSizeLabel.text = "\(note.fontSize)"
            editSizeSlider.value = Float(note.fontSize)
            contentEdit.textColor = UIColor.customColor
            if isDarkMode {
                let text = NSMutableAttributedString(attributedString: contentEdit.attributedText)
                text.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<text.length))
                if let location = note.range?.location, let length = note.range?.length {
                    text.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: location, length: length))
                }
                contentEdit.attributedText = text
            }

            if let location = note.range?.location, let length = note.range?.length {
                wordSelected = NSRange(location: location, length: length)
            }
            
        }
        editSizeSlider.isEnabled = !(attributedText?.string.isEmpty ?? true)
    }
    
    
    //MARK: - Highlight words
    @objc func highlightSelectedWord() {
        guard let attributedString = attributedText else {return}
        print(attributedString)
        if let range = Range(seletedRange ?? NSRange(location: 0, length: 1), in: contentEdit.text) {
            selectedWord = String(contentEdit.text[range])
            print(selectedWord as Any)
        }
        // The Issue is here
        if seletedRange != nil && selectedWord != nil {
            print("contentEdit selected Range is \(contentEdit.selectedRange)")
            attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value:UIColor.yellow , range: seletedRange ?? contentEdit.selectedRange)
            wordSelected = contentEdit.selectedRange
            if isDarkMode {
                attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: contentEdit.selectedRange)
            }
        }
        
        contentEdit.attributedText = attributedString
        attributedText = attributedString
        print(note as Any)
        
    }
    
    @IBAction func editSizeValue(_ sender: Any) {
        let sizeAttributedText = attributedText ?? NSMutableAttributedString(string: "")
        let roundedValue = lrintf(Float(editSizeSlider.value))
        editSizeLabel.text = "\(roundedValue)"
        sizeAttributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: CGFloat(roundedValue)), range: NSRange(0..<sizeAttributedText.length))
        fontSize = roundedValue
        let stripped = sizeAttributedText.strippedOriginalFont()
        attributedText = NSMutableAttributedString(attributedString: stripped ?? sizeAttributedText)
        contentEdit.attributedText = stripped
    }
    
    
    @IBAction func save(_ sender: Any) {
        print("pressing saving")
    }
    
    @IBAction func cancel(_ sender: Any) {
        print("pressing cancel")
    }
    
    
    //MARK: - Changing title
    
    @IBAction func gettingTitle(_ sender: Any) {
        if titleTextField.hasText != false {
            titleText = titleTextField.text
            print(titleText)
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToMain" {
            if note == nil {
                note = Note(noteTitle: titleText == "" ? "New Note" : titleText!, note: contentEdit.text, word: selectedWord, wordRange: Note.range(location: wordSelected?.location, length: wordSelected?.length), noteFontSize: fontSize)
                newNote = true
            } else {
                note.title = titleText == "" ? "New Note" : titleText!
                note.content = contentEdit.text
                note.word = selectedWord
                note.range = Note.range(location: wordSelected?.location, length: wordSelected?.length)
                note.fontSize = fontSize
            }
        }
    }
}

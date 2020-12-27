//
//  NoteEditingTableViewController.swift
//  TextViewTesting
//
//  Created by Nicole Li on 11/12/20.
//

import UIKit

class NoteEditingTableViewController: UITableViewController, UITextViewDelegate {
    
    let dateFormattor = DateFormatter()
    
    var note: Note!
    var newNote = false // editing
    var selectedRange: NSRange?
    var wordSelected: NSRange?
    var attributedText: NSMutableAttributedString?
    var selectedWord: String?
    var titleText: String?
    var fontSize: Int = 12
    
    @IBOutlet weak var editSizeSlider: UISlider!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentEdit: UITextView!
    @IBOutlet weak var editSizeLabel: UILabel!
    
    
//MARK: - When user edits text
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
    
//MARK: - When the user select text
    func textViewDidChangeSelection(_ textView: UITextView) {
        print(textView.selectedRange)
        selectedRange = textView.selectedRange
    }
    
//MARK: - Add UIMenus
    func addCustomMenu() {
        let addDefintion = UIMenuItem(title: "Add Word Defintion", action: #selector(highlightSelectedWord))
        let removeDefintion = UIMenuItem(title: "Remove Word Defintion", action: #selector(removeHighlightedWords))
        UIMenuController.shared.menuItems = [addDefintion, removeDefintion]
    
    }
    
//MARK: - Updateing all the colours when it is Dark or not.
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
    
//MARK: - When the app turns to the dark side
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
        
    }
    
    
//MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormattor.dateFormat = "dd/MM/yyyy"
        contentEdit.delegate = self
        editSizeSlider.value = Float(fontSize)
        addCustomMenu()
        if note == nil {
            title = "Add Note"
            contentEdit.attributedText = NSAttributedString(string: "")
            attributedText = NSMutableAttributedString(attributedString: contentEdit.attributedText)
            editSizeSlider.value = Float(fontSize)
            editSizeLabel.text = "12"
            contentEdit.textColor = UIColor.customColor
            
        } else {
            title = "Edit Note"
            titleTextField.text = note.title
            titleText = note.title
            fontSize = note.fontSize
            let attributedTextNote = note.makeNSAttributedString(string: note.content, fontSize: note.fontSize, rangeOfWord: Note.range(location: note.range?.location, length: note.range?.length))
            attributedText = NSMutableAttributedString(attributedString: attributedTextNote)
            contentEdit.attributedText = attributedTextNote
            editSizeLabel.text = "\(note.fontSize)"
            editSizeSlider.value = Float(note.fontSize)
            contentEdit.textColor = UIColor.customColor
            contentEdit.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            selectedWord = note.word
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
    
//MARK: - Remove highlighted words
    @objc func removeHighlightedWords() {
        if let nsrange = selectedRange {
            attributedText?.enumerateAttribute(.backgroundColor, in: nsrange, using: { (value, range, stop) in
                if let colour = value as? UIColor {
                    if colour == UIColor.yellow {
                        attributedText?.removeAttribute(.backgroundColor, range: nsrange)
                        if let swiftRange = Range(range, in: contentEdit.text) {
                            if String(contentEdit.text[swiftRange]) == selectedWord{
                                selectedWord = nil
                                wordSelected = nil
                            }
                        }
                        contentEdit.attributedText = attributedText
                    }
                }
            })
        }
    }
    
    //MARK: - Highlight words
    @objc func highlightSelectedWord() {
        guard let attributedString = attributedText else {return}
        print(attributedString)
        if let range = Range(selectedRange ?? NSRange(location: 0, length: 1), in: contentEdit.text) {
            selectedWord = String(contentEdit.text[range])
            print(selectedWord as Any)
        }
        // The Issue is here
        if selectedRange != nil && selectedWord != nil {
            print("contentEdit selected Range is \(contentEdit.selectedRange)")
            attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value:UIColor.yellow , range: selectedRange ?? contentEdit.selectedRange)
            wordSelected = contentEdit.selectedRange
            if isDarkMode {
                attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: contentEdit.selectedRange)
            }
        }
        
        contentEdit.attributedText = attributedString
        attributedText = attributedString
        print(note as Any)
        
    }
    
//MARK: - Size slider value change
    @IBAction func editSizeValue(_ sender: Any) {
        let sizeAttributedText = attributedText ?? NSMutableAttributedString(string: "")
        let roundedValue = lrintf(Float(editSizeSlider.value))
        editSizeLabel.text = "\(roundedValue)"
        sizeAttributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: CGFloat(roundedValue)), range: NSRange(0..<sizeAttributedText.length))
        fontSize = roundedValue
        let stripped = sizeAttributedText.strippedOriginalFont()
        if let strippedText = stripped {
        attributedText = NSMutableAttributedString(attributedString: strippedText)
        contentEdit.attributedText = strippedText
        }
    }
    
    
    @IBAction func save(_ sender: Any) {
        print("pressing saving")
    }
    
    @IBAction func cancel(_ sender: Any) {
        print("pressing cancel")
    }
    
    
    //MARK: - Changing title
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if titleTextField.hasText != false {
            titleText = titleTextField.text
            print(titleText)
        }
    }

    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToMain" {
            if note == nil {
                note = Note(noteTitle: titleText == "" ? "New Note" : titleText!, note: contentEdit.text, word: selectedWord, wordRange: Note.range(location: wordSelected?.location, length: wordSelected?.length), noteFontSize: fontSize, creationDate: dateFormattor.string(from: Date()))
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

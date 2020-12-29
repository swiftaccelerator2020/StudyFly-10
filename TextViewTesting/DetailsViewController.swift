//
//  DetailsViewController.swift
//  TextViewTesting
//
//  Created by Nicole Li on 10/12/20.
//

import UIKit

class DetailsViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    
    var colour = UIColor.customColor
    var note: Note!
    var printFormattor: UISimpleTextPrintFormatter = UISimpleTextPrintFormatter(text: "")
    var selectedWords: [String]? = []
    var HighlightedRanges: [Note.range]? = []
    
    @IBOutlet weak var noteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        printFormattor = UISimpleTextPrintFormatter(attributedText: Note.makeNSAttributedString(string: note.content, fontSize: note.fontSize, rangeOfWord: note.selectedDict))
        if let dic = note.selectedDict {
            for (value,key) in dic {
                selectedWords?.append(value)
                HighlightedRanges?.append(key)
        }
        updateNoteDisplay()
        let tap = UITapGestureRecognizer(target: self, action: #selector(myMethodToHandleTap(_:)))
        tap.delegate = self
        noteTextView.addGestureRecognizer(tap)
        }
    
    }
    private func updateColors() {

        let attributedString = NSMutableAttributedString(attributedString: noteTextView.attributedText)
            attributedString.removeAttribute(.foregroundColor, range: NSRange(0..<attributedString.length))
            attributedString.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<attributedString.length))
        
        if let dic = note.selectedDict {
            for (_,key) in dic {
                if let loaction = key.location, let length = key.length {
                    if isDarkMode {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: loaction, length: length))
                }
            }
        }
    }

        noteTextView.attributedText = attributedString
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
        
    }
    
    func updateNoteDisplay() {
        title = note.title
        noteTextView.attributedText = Note.makeNSAttributedString(string: note.content, fontSize: note.fontSize, rangeOfWord: note.selectedDict)
        if isDarkMode {
            let text = NSMutableAttributedString(attributedString: noteTextView.attributedText)
            text.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<text.length))
            if let dic = HighlightedRanges {
                for range in dic {
                    if let location = range.location, let length = range.length {
                        text.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: location, length: length))
                    }
                }
            }
            noteTextView.attributedText = text
        }
    }
    

    @IBAction func showActivityVC(_ sender: Any) {
        let text = note.content
        printFormattor = UISimpleTextPrintFormatter(attributedText: Note.makeNSAttributedString(string: note.content, fontSize: note.fontSize, rangeOfWord: note.selectedDict))
        
        
        let activityViewController = UIActivityViewController(activityItems: [text, printFormattor], applicationActivities: nil)
        
        present(activityViewController, animated: true)
    }
    
    @objc func myMethodToHandleTap(_ sender: UITapGestureRecognizer) {

        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager

        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;

        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // if index is valid then do something.
        if characterIndex < myTextView.textStorage.length {

            // print the character index
            print("character index: \(characterIndex)")

            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (myTextView.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")

            // check if the tap location intersects with any of the ranges
            if let dic = note.selectedDict {
                for (value,key) in dic {
                    if let location = key.location, let length = key.length {
                        let range = NSRange(location: location, length:length)
                        let attributeName = NSAttributedString.Key.backgroundColor
                        let attributeValue = myTextView.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
                        if NSIntersectionRange(myRange, range).length > 0, let attrValue = attributeValue {
                            print("You tapped on \(attributeName.rawValue) and the value is: \(attrValue)")
                            present(UIReferenceLibraryViewController(term: value), animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote",
            let navigationController = segue.destination as? UINavigationController,
            let dest = navigationController.viewControllers.first as? NoteEditingTableViewController {
            print("preparing segue to note editing")
            dest.note = note
            print(dest.note.content)
            }
        }
    }


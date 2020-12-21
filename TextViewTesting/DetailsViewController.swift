//
//  DetailsViewController.swift
//  TextViewTesting
//
//  Created by Nicole Li on 10/12/20.
//

import UIKit

class DetailsViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    
    var colour = UIColor.customColor
    var note: Note!
    var printFormattor: UISimpleTextPrintFormatter = UISimpleTextPrintFormatter(text: "")
    
    @IBOutlet weak var noteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        print(note.word)
        printFormattor = UISimpleTextPrintFormatter(attributedText: note.makeNSAttributedString(string: note.content, fontSize: note.fontSize, rangeOfWord: note.range))
        updateNoteDisplay()
        let tap = UITapGestureRecognizer(target: self, action: #selector(myMethodToHandleTap(_:)))
        tap.delegate = self
        noteTextView.addGestureRecognizer(tap)
    }
    
    
    private func updateColors() {
        let attributedString = NSMutableAttributedString(attributedString: noteTextView.attributedText)
            attributedString.removeAttribute(.foregroundColor, range: NSRange(0..<attributedString.length))
            attributedString.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<attributedString.length))
        
            if let loaction = note.range?.location, let length = note.range?.length {
                if isDarkMode {
                attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: loaction, length: length))
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
        noteTextView.attributedText = note.makeNSAttributedString(string: note.content, fontSize: note.fontSize, rangeOfWord: note.range)
        if isDarkMode {
            let text = NSMutableAttributedString(attributedString: noteTextView.attributedText)
            text.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<text.length))
            if let location = note.range?.location, let length = note.range?.length {
                text.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: location, length: length))
            }
            noteTextView.attributedText = text
        }
    }
    

    @IBAction func isPrinting(_ sender: Any) {
        
        // Getting the Air print view controller
        let printerController = UIPrintInteractionController.shared
        
        //Print Infomation
        let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = "Printing Note"
            printerController.printInfo = printInfo
        
        // Page Customisation
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormattor, startingAtPageAt: 0)
        // Customising page size
        let pageSize = CGSize(width: 595.2, height: 841.8)

        // create some sensible margins
        let pageMargins = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)

        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)

        // and here's the overall paper rectangle
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
            renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
            renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSMakeRange(0, renderer.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()

        for i in 0  ..< renderer.numberOfPages {
                UIGraphicsBeginPDFPage()

                renderer.drawPage(at: i, in: bounds)
            }

            UIGraphicsEndPDFContext()
            printerController.printPageRenderer = renderer
        
            printerController.present(animated: true, completionHandler: nil)
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

            // check if the tap location has a certain attribute
            let attributeName = NSAttributedString.Key.backgroundColor
            let attributeValue = myTextView.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
            if let value = attributeValue {
                print("You tapped on \(attributeName.rawValue) and the value is: \(value)")
                present(UIReferenceLibraryViewController(term: note.word ?? ""), animated: true, completion: nil)
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

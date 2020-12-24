//
//  ViewController.swift
//  TextViewTesting
//
//  Created by Zhang Shaoqiang on 30/11/20.
//

import UIKit
import Foundation
import Vision
import VisionKit

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VNDocumentCameraViewControllerDelegate {

    let dateFormattor = DateFormatter()
    var wordNeedingDef: String?
    var rangeOfSelection: NSRange?
    var rangeOfWord: NSRange?
    var printFormatter: UISimpleTextPrintFormatter = UISimpleTextPrintFormatter(text: "error")
    var imagePicked: UIImage?
    var processed: CGImage?
    var recognisedPara: String?
    var note: Note?
    var attributedText: NSMutableAttributedString?
    var fontSize: Int = 12
    var date: Date!
    //MARK: - Func land
    
    // For Photo Library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imagePicked = image
        self.imageView.image = image
        self.imageView.isHidden = false
        self.scanButton.isHidden = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    // For camera
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("Error with the camera picker!")
        print(error)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        print("Camera picker is cancelled!")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        print("Finish with camera")
        for i in 0 ..< scan.pageCount {
            let img = scan.imageOfPage(at: i)
            imagePicked = img
        }
        self.imageView.image = imagePicked
        self.imageView.isHidden = false
        self.scanButton.isHidden = false
        controller.dismiss(animated: true, completion: nil)
    }
    
    func handleDetectedText(request: VNRequest, error: Error?) {
        if let error = error {
            print("ERROR: \(error)")
            return
        }
        guard let observations = request.results as? [VNRecognizedTextObservation] else {return}
    
        let recognisedText = observations.compactMap { observation in
            
            return observation.topCandidates(1).first?.string
        }
        
        print("Recognised text: \(recognisedText.joined(separator: " \n"))")
        recognisedPara = recognisedText.joined(separator: " \n")
        
        DispatchQueue.main.async { [self] in
            textView.attributedText = NSAttributedString(string: recognisedPara ?? "recognisedPara is nil!")
            attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
            attributedText?.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<textView.attributedText.length))
            textView.attributedText = attributedText
            attributedText?.enumerateAttribute(.font, in: NSRange(0..<textView.attributedText.length), using: { (value, range, stop) in
                if let currentFont = value as? UIFont {
                    let fontSize = Float(currentFont.fontDescriptor.pointSize)
                    let roundedValue = lroundf(fontSize)
                    sizeLabel.text = "\(roundedValue)"
                    sizeSlider.value = Float(roundedValue)
                }
            })
            textView.isHidden = false
            activityIndicator.hidesWhenStopped = true
            activityIndicator.stopAnimating()
            sizeLabel.isHidden = false
            sizeSlider.isHidden = false
            titleTexField.isHidden = false
            scanButton.isHidden = true
            saveButton.isHidden = false
            date = Date()
        }
    }
    
    private func updateColors() {
        if let attributedString = attributedText {
            attributedString.removeAttribute(.foregroundColor, range: NSRange(0..<attributedString.length))
            attributedString.addAttribute(.foregroundColor, value: UIColor.customColor, range: NSRange(0..<attributedString.length))
            textView.attributedText = attributedString
            if let range = rangeOfWord {
                if isDarkMode {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                }
            }
            textView.attributedText = attributedText
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
        
    }
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleTexField: UITextField!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var sizeLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        dateFormattor.dateFormat = "dd/MM/yyyy"
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Plist is at \(documentPath.absoluteString)")
        scanButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10

        sizeLabel.isHidden = true
        sizeSlider.isHidden = true
        sizeSlider.minimumValue = 8
        sizeSlider.maximumValue = 50
        activityIndicator.isHidden = true
        scanButton.isHidden = true
        titleTexField.isHidden = true
        textView.isHidden = true
        imageView.isHidden = true
        textView.delegate = self
        textView.attributedText = NSAttributedString(string: textView.text)
        printFormatter = UISimpleTextPrintFormatter(text: textView.text)
        self.setupToHideKeyboardOnTapOnView()
        addCustomMenu()
        saveButton.isHidden = true
        
        
//MARK: - Alert
        let alert = UIAlertController(title: nil, message: "Select the source of your image", preferredStyle: .actionSheet)
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            let pickerController = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                pickerController.sourceType = .photoLibrary
                pickerController.delegate = self
                self.present(pickerController, animated: true, completion: nil)
            } else {
                print("Error with Image picker Photo Library")
            }
        }
    
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            let cameraPickerController = VNDocumentCameraViewController()
            cameraPickerController.delegate = self
            self.present(cameraPickerController, animated: true, completion: nil)
        }
    
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(photoLibrary)
        alert.addAction(camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
//MARK: - Getting Title
    @IBAction func textfieldChanged(_ sender: Any) {
        if titleTexField.hasText != false {
            note = Note(noteTitle: titleTexField.text == "" ? "New Note" : titleTexField.text!, note: textView.attributedText.string, word: wordNeedingDef, wordRange: Note.range(location: rangeOfWord?.location, length: rangeOfWord?.length), noteFontSize: fontSize, creationDate: dateFormattor.string(from: date))
            print(note as Any)
        }
    }
    
    
//MARK: - When keyboard will be shown
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                self.navigationController?.navigationBar.isHidden = true
            }
        }
    }

   
//MARK: - When keyboard will be hidden
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.navigationController?.navigationBar.isHidden = false
            self.view.frame.origin.y = 0
        }
    }

    
    
//MARK: - Highlighting words
    @objc func highlightSelectedWord() {
        guard let attributedString = attributedText else {return}
        if let range = Range(rangeOfSelection ?? NSRange(location: 0, length: 1), in: textView.text) {
            wordNeedingDef = String(textView.text[range])
            print(wordNeedingDef as Any)
        }
        // The Issue is no longer here
        if rangeOfSelection != nil && wordNeedingDef != nil {
            attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value:UIColor.yellow , range: textView.selectedRange)
            rangeOfWord = textView.selectedRange
            if isDarkMode {
                attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: textView.selectedRange)
            }
        }
        
        textView.attributedText = attributedString
        printFormatter = UISimpleTextPrintFormatter(attributedText: attributedString)
        note = Note(noteTitle: titleTexField.text == "" ? "New Note" : titleTexField.text!, note: attributedString.string, word: wordNeedingDef, wordRange: Note.range(location: rangeOfWord?.location, length: rangeOfWord?.length), noteFontSize: fontSize, creationDate: dateFormattor.string(from: date))
        attributedText = attributedString
        print(note as Any)

    }
    
    
//MARK: - Custom UIMenuItem
    func addCustomMenu() {
        let addDefintion = UIMenuItem(title: "Add Word Defintion", action: #selector(highlightSelectedWord))
        UIMenuController.shared.menuItems = [addDefintion]
    }
    

    
    
    
    
    //MARK: - Text view did change
    func textViewDidChange(_ textView: UITextView) {
        print(textView.attributedText)
        attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText?.enumerateAttribute(.backgroundColor, in: NSRange(location: 0, length: textView.attributedText.length), using: { (value, range, stop) in
            if let backgroundColour = value as? UIColor {
                if backgroundColour == UIColor.yellow {
                    print(range)
                    rangeOfWord = range
                    note = Note(noteTitle: titleTexField.text == "" ? "New Note" : titleTexField.text!, note: attributedText?.string ?? textView.attributedText.string, word: wordNeedingDef, wordRange: Note.range(location: rangeOfWord?.location, length: rangeOfWord?.length), noteFontSize: fontSize, creationDate: dateFormattor.string(from: date))
                    if isDarkMode {
                        attributedText?.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                    }
                }
            }
        })
    }
    

//MARK: - Finding Range
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("Selected Range: \(textView.selectedRange)")
        
        if let range = Range(textView.selectedRange, in: textView.text) {
            print(textView.text[range])
            rangeOfSelection = textView.selectedRange
            print("rangeOfSelection is \(rangeOfSelection)")
        }

    }

    

//MARK: - Font Size Change
    @IBAction func fontSizeChange(_ sender: Any) {
        guard let sizeAttributedText = attributedText else {return}
        let roundedValue = lrintf(Float(sizeSlider.value))
        sizeLabel.text = "\(roundedValue)"
        sizeAttributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: CGFloat(roundedValue)), range: NSRange(0..<sizeAttributedText.length))
        fontSize = roundedValue
        let stripped = sizeAttributedText.strippedOriginalFont()
        attributedText = NSMutableAttributedString(attributedString: stripped ?? sizeAttributedText)
        textView.attributedText = stripped
        printFormatter = UISimpleTextPrintFormatter(attributedText: textView.attributedText)        
        note = Note(noteTitle: titleTexField.text == "" ? "New Note" : titleTexField.text!, note: textView.attributedText.string, word: wordNeedingDef, wordRange: Note.range(location: rangeOfWord?.location, length: rangeOfWord?.location), noteFontSize: fontSize, creationDate: dateFormattor.string(from: date))
    }
    
//MARK: - Scan button
    @IBAction func isScanning(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        scanButton.isHidden = true
        guard let currentCGImage = imagePicked?.cgImage else { return }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")

        // set a gray value for the tint color
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")

        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return }

        let context = CIContext()

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            processed = cgimg
        }
        guard let bWImage = processed else {return}
        let request = VNImageRequestHandler(cgImage: bWImage)
        
        let textRequest = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try request.perform([textRequest])
            } catch {
                print("Error with text recognition.")
            }
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
            
        }
    
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saving" {
            if let nav = segue.destination as? UINavigationController {
                let destination = nav.topViewController as! NotesTableViewController
                destination.sentNote = note
                print(note?.title as Any)
            }
        }
    }
        
        
    
}



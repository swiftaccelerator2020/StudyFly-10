//
//  Note.swift
//  TextViewTesting
//
//  Created by Nicole Li on 10/12/20.
//

import Foundation
import UIKit


class Note: Codable {
    var title: String
    var content: String
    var selectedDict: [String : range]?
    var fontSize: Int
    var creationDate: String
    
    struct range: Codable {
        var location: Int?
        var length: Int?
    
    }
    
    init(noteTitle: String, note: String, selectedDict: [String : range]?, noteFontSize: Int, creationDate: String) {
        self.title = noteTitle
        self.content = note
        self.selectedDict = selectedDict
        self.fontSize = noteFontSize
        self.creationDate = creationDate
    }

    


    
    static func getArchiveURL() -> URL {
        let plistName = "noteArray"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Plist location is \(documentsPath.absoluteString)")
        return documentsPath.appendingPathComponent(plistName).appendingPathExtension("plist")
        }

    static func saveToFile(notes: [Note]) {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encodedNotes = try? propertyListEncoder.encode(notes)
        try? encodedNotes?.write(to: archiveURL, options: .noFileProtection)
    }

    static func loadFromFile() -> [Note]? {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
        guard let retrievedNotesData = try? Data(contentsOf: archiveURL) else { return nil }
        guard let decodedNotes = try? propertyListDecoder.decode(Array<Note>.self, from: retrievedNotesData) else { return nil }
        return decodedNotes
    }
        
    static func makeNSRange(from range: range) -> NSRange{
        if let location = range.location, let length = range.length {
            let nsRange = NSRange(location: location, length: length)
            return nsRange
        } else {
            return NSRange(location: 0, length: 0)
        }
    }
    
    static func makeNSAttributedString(string: String, fontSize: Int, rangeOfWord: [String : range]?) -> NSAttributedString {
        let size = CGFloat(fontSize)
        var attributedText: NSMutableAttributedString
        attributedText = NSMutableAttributedString(string: string)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: size), range: NSRange(0..<attributedText.length))
        if let wordRange = rangeOfWord{
            for (_,key) in wordRange {
                if let location = key.location, let length = key.length {
                    attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: NSRange(location: location, length: length))
                }
            }
        }
            print(attributedText)
            return attributedText
    }
}

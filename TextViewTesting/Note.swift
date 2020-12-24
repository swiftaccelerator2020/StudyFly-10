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
    var word: String?
    var range: range?
    var fontSize: Int
    var creationDate: String
    
    struct range: Codable {
        var location: Int?
        var length: Int?
    
    }
    
    init(noteTitle: String, note: String, word: String?, wordRange: range?, noteFontSize: Int, creationDate: String) {
        self.title = noteTitle
        self.content = note
        self.word = word
        self.range = wordRange
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
        
    func makeNSAttributedString(string: String, fontSize: Int, rangeOfWord: range?) -> NSAttributedString {
        let size = CGFloat(fontSize)
        var attributedText: NSMutableAttributedString
        attributedText = NSMutableAttributedString(string: string)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: size), range: NSRange(0..<attributedText.length))
        if let wordRange = rangeOfWord {
            attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: NSRange(location: wordRange.location ?? 0, length: wordRange.length ?? 0))
        }
            print(attributedText)
            return attributedText
    }
}

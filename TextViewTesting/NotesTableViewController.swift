//
//  NotesTableViewController.swift
//  TextViewTesting
//
//  Created by Nicole Li on 11/12/20.
//

import UIKit

class NotesTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    var notes: [Note] = []
    var addNote = false
    var sentNote: Note?
    let dateFormattor = DateFormatter()
    let calender = Calendar.current
    var tapGesture: UITapGestureRecognizer!
    static let usernameKey = "My"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormattor.dateFormat = "dd/MM/yyyy"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(editName(_:)))
        tapGesture.delegate = self
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let loadedNotes = Note.loadFromFile() ?? []
            notes = loadedNotes
            if let isNote = sentNote {
                isNote.creationDate = dateFormattor.string(from: Date())
                notes.append(isNote)
                print(notes.count)
                Note.saveToFile(notes: notes)
            }
        
        
        
        
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: NotesTableViewController.usernameKey) {
            self.title = "\(name)'s Studyfly"
            print(self.title as Any)
            return
            }
        }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if addNote == true {
            performSegue(withIdentifier: "addNotes", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove gesture recognizer from navigation bar when view is about to disappear
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGesture)
    }
//MARK: - Allow user to edit name

    @objc func editName(_ sender: UITapGestureRecognizer) {
        let defaults = UserDefaults.standard
        let alert = UIAlertController(title: "Edit your name", message: nil, preferredStyle: .alert)
    
        let saveName = UIAlertAction(title: "Save", style: .default) { (action) in
            if let textField = alert.textFields?.first, let name = textField.text, textField.hasText{
                self.title = "\(name)'s StudyFly"
                defaults.setValue(name, forKey: NotesTableViewController.usernameKey)
            }
            
        }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
            alert.addTextField { (textField) in
                textField.text = defaults.string(forKey: NotesTableViewController.usernameKey)
        }
        alert.addAction(saveName)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NotesTableViewCell

        cell.titleLabel.text = notes[indexPath.row].title
        cell.contentLabel.text = notes[indexPath.row].content
        cell.dateLabel.text = notes[indexPath.row].creationDate
        print(cell.dateLabel.text as Any)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            Note.saveToFile(notes: notes)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let note = notes.remove(at: fromIndexPath.row)
        notes.insert(note, at: to.row)
        Note.saveToFile(notes: notes)
        tableView.reloadData()
    }
    

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showNote",
            let destination = segue.destination as? DetailsViewController,
            let currentlySelectedNote = tableView.indexPathForSelectedRow{
                
                destination.note = notes[currentlySelectedNote.row]
            print("Note is \(destination.note.title)")
        }
        
        
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        if segue.identifier == "unwindToMain" {
            let source = segue.source as! NoteEditingTableViewController
            if source.newNote {
                
                notes.append(source.note)
                Note.saveToFile(notes: notes)
                if addNote {
                    addNote = false
                }
            } else {
                print(tableView.indexPathForSelectedRow)
                if let currentlySelectedNote = tableView.indexPathForSelectedRow {
                    notes.remove(at: currentlySelectedNote.row)
                    notes.insert(source.note, at: currentlySelectedNote.row)
                    Note.saveToFile(notes: notes)
                }
            }
            tableView.reloadData()
        }
    
    }

}

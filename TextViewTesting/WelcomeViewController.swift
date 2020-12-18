//
//  WelcomeViewController.swift
//  TextViewTesting
//
//  Created by Zhang Shaoqiang on 6/12/20.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var newNoteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanButton.layer.cornerRadius = 25
        newNoteButton.layer.cornerRadius = 25
        imageView.image = UIImage(named: "butterfly")
        imageView.image = imageView.image?.roundedImage
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: NotesTableViewController.usernameKey) {
            
        } else {
            let alert = UIAlertController(title: "Hello! What's your name?", message: "", preferredStyle: .alert)
            
            // Cancel action has a nil handler—does nothing, just cancels
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            // OK action asks for the text from the alert's first text field
            let okAction = UIAlertAction(title: "Save", style: .default) { (action) in
                if let textField = alert.textFields?.first,
                   let text = textField.text {
                    print(text)
                    let defaults = UserDefaults.standard
                    defaults.set(text, forKey: NotesTableViewController.usernameKey)
                }
            }
            alert.addAction(okAction)
            
            // Another closure! This one lets you configure the textField.
            alert.addTextField { (textField) in
                textField.placeholder = "Please enter your name."
            }
            print("Alert should be shown soon")
            present(alert, animated: true)
        }
    }
   
    @IBAction func needScanning(_ sender: Any) {
       
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFromWelcome" {
            guard let navi = segue.destination as? UINavigationController else {return}
            guard let destination = navi.topViewController as? NotesTableViewController else {return}
            destination.addNote = true
        }
    }




}

extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
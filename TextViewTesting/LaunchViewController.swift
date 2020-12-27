//
//  LaunchViewController.swift
//  TextViewTesting
//
//  Created by Zhang Shaoqiang on 26/12/20.
//

import UIKit

class LaunchViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageView.image?.roundedImage
        view.backgroundColor = UIColor.customColor
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

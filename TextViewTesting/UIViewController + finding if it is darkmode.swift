//
//  UIViewController + finding if it is darkmode.swift
//  TextViewTesting
//
//  Created by Zhang Shaoqiang on 20/12/20.
//

import Foundation
import UIKit

extension UIViewController {
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }

}

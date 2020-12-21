//
//  UIColour + changing colour based on UIStyle.swift
//  TextViewTesting
//
//  Created by Zhang Shaoqiang on 20/12/20.
//

import Foundation
import UIKit

extension UIColor {
    
    
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
    
    if #available(iOS 13.0, *) {
        return UIColor(dynamicProvider: {
            switch $0.userInterfaceStyle {
            case .dark:
                return dark
            case .light, .unspecified:
                return light
            @unknown default:
                assertionFailure("Unknown userInterfaceStyle: \($0.userInterfaceStyle)")
                return light
            }
        })
    }
    
    // iOS 12 and earlier
    return light
}

private static let lightMode = UIColor.black

private static let darkMode = UIColor.white

static let customColor = UIColor.dynamic(light: lightMode, dark: darkMode)

}

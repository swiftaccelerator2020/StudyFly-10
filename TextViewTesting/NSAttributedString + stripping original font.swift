//
//  NSAttributedString + stripping original font.swift
//  TextViewTesting
//
//  Created by Zhang Shaoqiang on 23/12/20.
//

import Foundation

extension NSAttributedString {
  
func strippedOriginalFont() -> NSAttributedString? {
    let mutableCopy = self.mutableCopy() as? NSMutableAttributedString
    mutableCopy?.removeAttribute(NSAttributedString.Key(rawValue: "NSOriginalFont"), range: NSMakeRange(0, self.length))
    return mutableCopy?.copy() as? NSAttributedString
    }
}

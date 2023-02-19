//
//  UIColor-Extension.swift
//  chatAppWithFirebase
//
//  Created by 海老原颯希 on 2023/01/22.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}

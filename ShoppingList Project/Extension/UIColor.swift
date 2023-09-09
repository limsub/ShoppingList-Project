//
//  UIColor.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/09.
//

import UIKit

// 다크모드 대응
extension UIColor {
    
    static var labelColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .light {
                return .black
            } else {
                return .white
            }
        }
    }
    

}

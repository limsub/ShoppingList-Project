//
//  ReusableProtocol.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit

protocol ReusableViewProtocol: AnyObject {
    static var reuseIdentifier: String { get }
    
}

extension UICollectionViewCell: ReusableViewProtocol {
    static var reuseIdentifier: String {
        return description()
//        return String(describing: self)
    }
}



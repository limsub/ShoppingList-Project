//
//  UIButton.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/23.
//

import UIKit

extension UIButton {
    var whatSort: SortCase? {
        switch self.titleLabel?.text {
        case SortCase.accuracy.title:
            return SortCase.accuracy
        case SortCase.date.title:
            return SortCase.date
        case SortCase.highPrice.title:
            return SortCase.highPrice
        case SortCase.lowPrice.title:
            return SortCase.lowPrice
        default: return nil
        }
    }
}

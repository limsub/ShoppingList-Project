//
//  SortEnum.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit

enum SortCase {
    case accuracy
    case date
    case highPrice
    case lowPrice
    
    var query: String {
        switch self {
        case .accuracy:
            return "sim"
        case .date:
            return "date"
        case .highPrice:
            return "dsc"
        case .lowPrice:
            return "asc"
        }
    }
    
    var title: String {
        switch self {
        case .accuracy:
            return " 정확도 "
        case .date:
            return " 날짜순 "
        case .highPrice:
            return " 가격높은순 "
        case .lowPrice:
            return " 가격낮은순 "
        }
    }
}

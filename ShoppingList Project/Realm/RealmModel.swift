//
//  RealmModel.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/08.
//

import UIKit
import RealmSwift

class LikesTable: Object {

    
    
    @Persisted(primaryKey: true) var _id: ObjectId
    // 옵셔널은 아닌데, 빈 문자열일 순 있다
    @Persisted var productId: String
    @Persisted var mallName: String
    @Persisted var title: String
    @Persisted var lprice: String
    @Persisted var imageLink: String
    @Persisted var imageData: Data?
    
    convenience init(productId: String, mallName: String, title: String, lprice: String, imageLink: String, imageData: Data? = nil) {
        self.init()
        
        self.productId = productId
        self.mallName = mallName
        self.title = title
        self.lprice = lprice
        self.imageLink = imageLink
        self.imageData = imageData
    }
    
}

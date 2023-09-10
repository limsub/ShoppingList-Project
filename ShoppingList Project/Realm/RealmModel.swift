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
    @Persisted var productId: String
    @Persisted var mallName: String
    @Persisted var title: String
    @Persisted var lprice: String
    @Persisted var imageLink: String
    @Persisted var imageData: Data?
    
    @Persisted var time: Date   // 좋아요 목록 창에 등록순으로 띄워주기 위함
    
    convenience init(productId: String, mallName: String, title: String, lprice: String, imageLink: String, imageData: Data? = nil) {
        self.init()
        
        self.productId = productId
        self.mallName = mallName
        self.title = title
        self.lprice = lprice
        self.imageLink = imageLink
        self.imageData = imageData
        
        time = Date()
    }
    
}

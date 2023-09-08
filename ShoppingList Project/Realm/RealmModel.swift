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
    @Persisted var Iprice: String
    @Persisted var ImageLink: String
    @Persisted var ImageData: Data?
    
    convenience init(_id: ObjectId, productId: String, mallName: String, title: String, Iprice: String, ImageLink: String, ImageData: Data? = nil) {
        self.init()
        
        self._id = _id
        self.productId = productId
        self.mallName = mallName
        self.title = title
        self.Iprice = Iprice
        self.ImageLink = ImageLink
        self.ImageData = ImageData
    }
    
}

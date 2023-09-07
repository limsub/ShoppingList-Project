//
//  ShoppingAPIManager.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit
import Alamofire


class ShoppingAPIManager {
    
    // Singleton Pattern
    static let shared = ShoppingAPIManager()
    private init() { }
    
    let header: HTTPHeaders = [
        "X-Naver-Client-Id" : APIKey.naverClientId,
        "X-Naver-Client-Secret" : APIKey.naverClientSecret
    ]
    
    func callShoppingList(_ query: String, completionHandler: @escaping (Shopping) -> Void ) {
        
        // https://openapi.naver.com/v1/search/shop.json
        // https://openapi.naver.com/v1/search/shop.json?query=apple
        
        guard let txt = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else  { return }
        
        guard let url = URL(string: "https://openapi.naver.com/v1/search/shop.json?query=\(txt)") else { return }
        
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200...500)
            .responseDecodable(of: Shopping.self) { response in
                
                let statusCode = response.response?.statusCode ?? 500
                
                if (statusCode == 200) {
                    guard let value = response.value else { return }
                    completionHandler(value)
                } else {
                    print("Error!! StatusCode : \(statusCode)")
                    print("Error!! response  \(response)")
                }
                
                
            }
        
    }
}

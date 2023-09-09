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
    
    func callShoppingList(_ query: String, _ sortType: SortCase, _ start: Int, completionHandler: @escaping (Shopping) -> Void, showAlertWhenNetworkDisconnected: @escaping () -> Void ) {
        
        // 네트워크 체크
        if !NetworkMonitor.shared.isConnected {
            print("네트워크 통신이 불가합니다")
            showAlertWhenNetworkDisconnected()
            return
        }
        
        
        // https://openapi.naver.com/v1/search/shop.json
        // https://openapi.naver.com/v1/search/shop.json?query=apple
        
        // 기본 주소
        guard let url = URL(string: "https://openapi.naver.com/v1/search/shop.json") else { return }
        
        // 매개변수 (쿼리 스트링)
        // 1. 검색 문자열
//        guard let txt = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else  { return }
        
        // 2. 한 번에 표시할 개수 = 30
        let displayCntQuery = 30
        
        // 3. 정렬 방법
        let sortQuery = sortType.query
        
        // 4. 시작 위치 1 -> 31 -> 61 -> 91  done
        let startQuery = start
        
        let parameter: Parameters = [
            "query": query,
            "display": displayCntQuery,
            "start": startQuery,
            "sort": sortQuery,
        ]
        
        
        AF.request(url, method: .get, parameters: parameter, headers: header)
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

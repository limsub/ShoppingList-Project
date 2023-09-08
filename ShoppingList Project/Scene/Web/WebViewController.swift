//
//  WebViewController.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/08.
//

import UIKit
import WebKit

// product를 다이렉트로 설정/해제하면 안됨.
// 가지고 있는 데이터로 새로 task를 만들고, 그걸 기반으로 추가 / 삭제 해야함
// 그래서 값 전달로 받은 product는 딱 정보 빼오는 용도로만 쓴다고 생각하자


class WebViewController: BaseViewController, WKUIDelegate {
    
    var webView = WKWebView()
    
    let repository = LikesTableRepository()
    
    /* ===== 값전달 인스턴스 ===== */
    var product: LikesTable?
    var likeOrNot: Bool = false     // 최대한 빠르게 화면에 보여주기 위함
    
    
    var heartButton: UIBarButtonItem?
    var newProduct: LikesTable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let product = product else { return }
        
        // new product 생성
        newProduct = LikesTable(productId: product.productId, mallName: product.mallName, title: product.title, lprice: product.lprice, imageLink: product.imageLink, imageData: product.imageData)
        
        // + image Data 저장 -> 이미 데이터 처리가 되어있어서 바로 가능
        
        
        
        loadWebView()
        
        /* === 네비게이션 커스텀 === */
        title = product.title
        
        /* === 좋아요 버튼 (rightBarButtonItem) === */
        heartButton = UIBarButtonItem(
            image: UIImage(systemName: (likeOrNot) ? "heart.fill" : "heart"),
            style: .plain,
            target: self,
            action: #selector(heartButtonClicked)
        )
        
        
        navigationItem.rightBarButtonItem = heartButton
        
        
    }
    
    @objc
    func heartButtonClicked() {
        
        
        
        // 좋아요 목록에서 해제
        if likeOrNot {
            
            // 1. 찾기
            guard let newProduct = newProduct else { return }
            guard let task = repository.fetch(newProduct.productId).first else { return }
            

            // 2. 지우기
            repository.deleteItem(task)
            
            
            // 3. 이미지 변경
            heartButton?.image = UIImage(systemName: "heart")
        }
        
        // 좋아요 목록에 추가
        else {
            guard let newProduct = newProduct else { return }
            repository.createItem(newProduct)
            heartButton?.image = UIImage(systemName: "heart.fill")
            
        }
        
    }
    
   
    
    override func setConfigure() {
        super.setConfigure()
        
        view.addSubview(webView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

}

extension WebViewController {
    
    /* === webView 로딩 === */
    func loadWebView() {
        
        guard let product = self.product else { return }
        
        guard let url = URL(string: "https://msearch.shopping.naver.com/product/\(product.productId)") else { return }
        
            
        let request = URLRequest(url: url)
            
        
        self.webView.load(request)
        
            
        // main thread 에러.. webView 때문에 출력되는데 글로벌로 돌리면 아예 애러남
        
    }
    
    // 새로고침

    
    // 뒤로가기
    
    
    // 앞으로 가기
    
}

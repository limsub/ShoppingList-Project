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
    
    /* ===== 인스턴스 ===== */
    var webView = WKWebView()
    var heartButton: UIBarButtonItem?
    
    let backwardButton = makeCircleButton()
    let forwardButton = makeCircleButton()
    let reloadButton = makeCircleButton()
    
    static func makeCircleButton() -> UIButton{
        let button = UIButton()
        
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 20
        
        button.tintColor = .black
        
        return button
    }
    
    
    /* ===== repository pattern ====== */
    let repository = LikesTableRepository()
    var newProduct: LikesTable?
    
    
    /* ===== 값전달 인스턴스 ===== */
    var product: LikesTable?
    var likeOrNot: Bool = false
    
    
    /* ===== viewDidLoad ===== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("좋아요 여부 : \(likeOrNot)")
        
        guard let product = product else { return }
        
        // new product 생성
        newProduct = LikesTable(productId: product.productId, mallName: product.mallName, title: product.title, lprice: product.lprice, imageLink: product.imageLink, imageData: product.imageData)
        print(newProduct)
        
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
        
        print("좋아요 버튼이 눌렸습니다")
        
        
        // 좋아요 목록에서 해제
        if likeOrNot {
            
            print("좋아요 목록에서 해제됩니다")
            
            // 1. 찾기
            guard let newProduct = newProduct else { return }
            guard let task = repository.fetch(newProduct.productId).first else { return }
            print("저장된 데이터를 찾았습니다 :")
            print(task)

            // 2. 데이터 제거
            repository.deleteItem(task)
            
            // 3. 이미지 변경
            heartButton?.image = UIImage(systemName: "heart")
            
            // 4. 인스턴스 데이터 변경
            likeOrNot = false
        }
        
        // 좋아요 목록에 추가
        else {
            
            print("좋아요 목록에 추가됩니다")
            
            // 1. 데이터 생성 (다른 PK를 만들어주기 위함)
            guard let newProduct = newProduct else { return }
            
            let addProduct = LikesTable(productId: newProduct.productId, mallName: newProduct.mallName, title: newProduct.title, lprice: newProduct.lprice, imageLink: newProduct.imageLink, imageData: newProduct.imageData)
            
            // 2. 데이터 추가
            repository.createItem(addProduct)
            
            // 3. 이미지 변경
            heartButton?.image = UIImage(systemName: "heart.fill")
            
            // 4. 인스턴스 데이터 변경
            likeOrNot = true
        }
        
    }
    
   
    /* ===== set configure / constraints ===== */
    override func setConfigure() {
        super.setConfigure()
        
        view.addSubview(webView)
        view.addSubview(backwardButton)
        view.addSubview(forwardButton)
        view.addSubview(reloadButton)
        
        backwardButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        forwardButton.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        reloadButton.setImage(UIImage(systemName: "goforward"), for: .normal)
        backwardButton.addTarget(self, action: #selector(backwardButtonClicked), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonClicked), for: .touchUpInside)
        reloadButton.addTarget(self, action: #selector(reloadButtonClicked), for: .touchUpInside)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        backwardButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalTo(view).inset(30)
        }
        reloadButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalTo(view)
        }
        forwardButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(view).inset(30)
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
        
        // [Security] This method should not be called on the main thread as it may lead to UI unresponsiveness.
    }
    
    // 새로고침
    @objc
    func reloadButtonClicked() {
        webView.reload()
    }
    
    // 뒤로가기
    @objc
    func backwardButtonClicked() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    // 앞으로 가기
    @objc
    func forwardButtonClicked() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
}

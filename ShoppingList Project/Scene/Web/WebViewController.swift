//
//  WebViewController.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/08.
//

import UIKit
import WebKit

final class WebViewController: BaseViewController, WKUIDelegate {
    
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
    
    let disConnectedView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.text = "네트워크 연결이 끊겼습니다\n연결 상태를 확인해주세요"
        label.textColor = .lightGray
        label.numberOfLines = 2
        label.textAlignment = .center
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "xmark")
        imageView.tintColor = .lightGray
        
        view.addSubview(imageView)
        view.addSubview(label)
        imageView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(100)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        
        return view
    }()
    
    
    /* ===== repository pattern ====== */
    let repository = LikesTableRepository()
    var newProduct: LikesTable?
    
    
    /* ===== 값전달 인스턴스 ===== */
    var product: LikesTable?
    var previousVC: UIViewController?  // 이전 뷰컨트롤러 저장 (탭바 클릭 시 확인용)
    var likeOrNot: Bool = false
    
    
    /* ===== viewDidLoad ===== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        webView.navigationDelegate = self
        
        // newProduct 인스턴스 생성
        guard let product = product else { return }
        newProduct = LikesTable(productId: product.productId, mallName: product.mallName, title: product.title, lprice: product.lprice, imageLink: product.imageLink, imageData: product.imageData)
        
        
        loadWebView()
        
        
        /* === 네비게이션 커스텀 === */
        title = setTitleText(product.title)
        heartButton = UIBarButtonItem(
            image: UIImage(systemName: (likeOrNot) ? "heart.fill" : "heart"),
            style: .plain,
            target: self,
            action: #selector(heartButtonClicked)
        )
        navigationItem.rightBarButtonItem = heartButton
    }
    
    
    /* ===== viewWillAppear ===== */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 좋아요 여부 확인
        guard let newProduct = newProduct else { return }
        if repository.fetch(newProduct.productId).isEmpty {
            likeOrNot = false
        } else {
            likeOrNot = true
        }
        
        // 좋아요 버튼 업데이트
        guard let heartButton = heartButton else { return }
        heartButton.image = UIImage(systemName: (likeOrNot) ? "heart.fill" : "heart")
        
        
        tabBarController?.delegate = self
    }
    
    @objc
    private func heartButtonClicked() {
        
        // 좋아요 목록에서 해제
        if likeOrNot {
            // 1. 찾기
            guard let newProduct = newProduct else { return }
            guard let task = repository.fetch(newProduct.productId).first else { return }

            // 2. 데이터 제거
            repository.deleteItem(task)
            
            // 3. 좋아요 버튼 업데이트
            heartButton?.image = UIImage(systemName: "heart")
            
            // 4. 인스턴스 데이터 변경
            likeOrNot = false
        }
        
        // 좋아요 목록에 추가
        else {
            
            // 1). 잘 들어옴 -> 잘 추가
            // 2). 네트워크 끊긴 상태에서 들어옴 -> imageData 저장 불가능
            
            // 1. 데이터 생성 (다른 PK를 만들어주기 위함)
            guard let newProduct = newProduct else { return }
            
            let addProduct = LikesTable(productId: newProduct.productId, mallName: newProduct.mallName, title: newProduct.title, lprice: newProduct.lprice, imageLink: newProduct.imageLink, imageData: newProduct.imageData)
            
            if (addProduct.imageData == nil) {
                showAlert("이전 화면에서 이미지 데이터를 받아오지 못했습니다", "이미지를 제외한 데이터만 저장됩니다")
            }
            
            // 2. 데이터 추가
            repository.createItem(addProduct)
            
            // 3. 좋아요 버튼 업데이트
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
        view.addSubview(disConnectedView)
        
        backwardButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        forwardButton.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        reloadButton.setImage(UIImage(systemName: "goforward"), for: .normal)
        backwardButton.addTarget(self, action: #selector(backwardButtonClicked), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonClicked), for: .touchUpInside)
        reloadButton.addTarget(self, action: #selector(reloadButtonClicked), for: .touchUpInside)
        
        disConnectedView.isHidden = true
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
        
        disConnectedView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(200)
        }
        
    }
}

extension WebViewController: WKNavigationDelegate {
    // 로드 실패
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = true
        disConnectedView.isHidden = false
        print("로드 실패")
    }
    
    // 로드 성공
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.isHidden = false
        disConnectedView.isHidden = true
        print("로드 성공")
    }
}

extension WebViewController {
    
    /* === webView 로딩 === */
    private func loadWebView() {
        
        guard let newProduct = self.newProduct else { return }
        guard let url = URL(string: "https://msearch.shopping.naver.com/product/\(newProduct .productId)") else { return }
        let request = URLRequest(url: url)
        self.webView.load(request)
        
        // [Security] This method should not be called on the main thread as it may lead to UI unresponsiveness.
    }
    
    // 새로고침
    @objc
    private func reloadButtonClicked() {
        // 로드 실패한 상황이었으면 웹뷰 다시 로드한다
        if (webView.isHidden) {
            loadWebView()
        }
        webView.reload()
    }
    
    // 뒤로가기
    @objc
    private func backwardButtonClicked() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    // 앞으로 가기
    @objc
    private func forwardButtonClicked() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
}


/* ========== tabBar extension ========== */
extension WebViewController: UITabBarControllerDelegate {
    
    // 탭 아이템 선택 시 이전 화면 돌아가기
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let currentIndex = tabBarController.selectedIndex
        let currentVC = tabBarController.viewControllers?[currentIndex]

        if  currentVC != previousVC { return true }
        
        navigationController?.popViewController(animated: true)

        return false
    }
}

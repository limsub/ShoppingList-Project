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
    
    var previousVC: UIViewController?
    
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
    var likeOrNot: Bool = false
    
    
    /* ===== viewDidLoad ===== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        webView.navigationDelegate = self
        
        guard let product = product else { return }
        
        // new product 생성 (현재 화면에 떠있는 제품)
        newProduct = LikesTable(productId: product.productId, mallName: product.mallName, title: product.title, lprice: product.lprice, imageLink: product.imageLink, imageData: product.imageData)
        print(newProduct)
        
        // + image Data 저장 -> 이미 데이터 처리가 되어있어서 바로 가능
        
        // likeOrNot을 값전달로 받긴 했지만, 그건 초기값이고
        // 실질적인 값은 realm을 통해서 찾아야 한다
        // productId가 있으면 likeOrNot = true
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let newProduct = newProduct else { return }
        
        if repository.fetch(newProduct.productId).isEmpty {
            likeOrNot = false
        } else {
            likeOrNot = true
        }
        
        guard let heartButton = heartButton else { return }
        heartButton.image = UIImage(systemName: (likeOrNot) ? "heart.fill" : "heart")
        
        tabBarController?.delegate = self
        
        
    }
    
    func setTitleText(_ sender: String) -> String {
        
        var ans = sender
        
        // <b> 태그 제거
        ans = ans.replacingOccurrences(of: "<b>", with: "")
        ans = ans.replacingOccurrences(of: "</b>", with: "")
        
        // count 10 이상이면 잘라주기
        if ans.count > 10 {
            let index = ans.index(ans.startIndex, offsetBy: 10)
            ans = String(ans.prefix(upTo: index))
            ans = ans + "..."
        }
        
        return ans
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
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = true
        disConnectedView.isHidden = false
        print("로드 실패")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.isHidden = false
        disConnectedView.isHidden = true
        print("로드 성공")
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
        // 로드 실패한 상황이었으면 웹뷰 다시 로드한다
        if (webView.isHidden) {
            loadWebView()
        }
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

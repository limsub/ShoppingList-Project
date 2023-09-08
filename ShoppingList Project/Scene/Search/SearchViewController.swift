//
//  SearchViewController.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit

// 검색 창
// 인스턴스
    // 서치바
    // 버튼 4개
    // 컬렉션뷰


// 일단 지금 생각
    // 네비게이션 아이템에 서치바 포함
    // 버튼 4개랑 컬렉션뷰 따로


class SearchViewController: BaseViewController {
    
    
    
    /* ========== 컬렉션뷰 데이터 ========== */
    var data: [Item] = []
    var startNum: Int = 1   // pagination (1 -> 31 -> 61 -> 91 -> done)
    var totalNum: Int = 0   // pagination 시 예외처리용 (totalNum < indexPath.row -> 페이지 추가 x. 애초에 넘어가지도 않겠네)
    var howSort = SortCase.accuracy    // 정렬 기준. 디폴트 : 정확도
    
    /* ========== repository pattern ========== */
    let repository = LikesTableRepository()
    
    /* ========== 인스턴스 생성 ========== */
    let searchController = UISearchController(searchResultsController: nil)
    
    static func makeSortButton(_ type: SortCase) -> UIButton {
        let button = UIButton()
        
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        
        button.setTitle(type.title, for: .normal)
        
        return button
    }
    
    let accuracySortButton = makeSortButton(SortCase.accuracy)
    let dateSortButton = makeSortButton(SortCase.date)
    let highPriceSortButton = makeSortButton(SortCase.highPrice)
    let lowPriceSortButton = makeSortButton(SortCase.lowPrice)
    
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        
        view.backgroundColor = .black
        
        view.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier)
        
        view.dataSource = self
        view.delegate = self
        view.prefetchDataSource = self
        
        return view
    }()
    
    
    /* ========== viewDidLoad ========== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repository.printURL()
        
        view.backgroundColor = .black
        
        
        /* === 네비게이션 아이템 및 서치바 커스텀 === */
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = false   // 네비게이션 타이틀 계속 띄워주기
        navigationItem.hidesSearchBarWhenScrolling = false              // 스크롤 시에도 서치바 유지
        title = "검색 창"
        searchController.searchBar.delegate = self
//        navigationItem.searchController?.searchBar.backgroundColor = .black
//        navigationItem.searchController?.searchBar.barTintColor = .lightGray
        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = .darkGray
//        navigationItem.titleView?.backgroundColor = .black
        navigationController?.navigationBar.backgroundColor = .black
//        navigationController?.navigationBar.tintColor = .white
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
//        searchController.automaticallyShowsCancelButton
        
//        searchController.searchBar.placeholder = "검색어를 입력하세요."
        searchController.searchBar.tintColor = .white
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        
        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "검색어를 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
//        let image = UIImage(systemName: "magnifyingglass")?.withTintColor(.white, renderingMode: .alwaysTemplate)
//        searchController.searchBar.setImage(image, for: UISearchBar.Icon.search, state: .normal)
        
//
//
//
//        //왼쪽 서치아이콘 이미지 세팅하기
//        searchController.searchBar.setImage(UIImage(named: "icSearchNonW"), for: UISearchBar.Icon.search, state: .normal)
//                //오른쪽 x버튼 이미지 세팅하기
//        searchController.searchBar.setImage(UIImage(named: "icCancel"), for: .clear, state: .normal)
//
//        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
////                    //서치바 백그라운드 컬러
////                    textfield.backgroundColor = UIColor.black
////                    //플레이스홀더 글씨 색 정하기
////                    textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
////                    //서치바 텍스트입력시 색 정하기
////                    textfield.textColor = UIColor.white
//                    //왼쪽 아이콘 이미지넣기
//                    if let leftView = textfield.leftView as? UIImageView {
//                        leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
//                        //이미지 틴트컬러 정하기
//                        leftView.tintColor = UIColor.white
//                    }
//                    //오른쪽 x버튼 이미지넣기
//                    if let rightView = textfield.rightView as? UIImageView {
//                        rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
//                        //이미지 틴트 정하기
//                        rightView.tintColor = UIColor.white
//                    }
//
//                }
        
        
        
        
        /* === 정렬 버튼 addTarget === */
        accuracySortButton.addTarget(self, action: #selector(accuracySortButtonClicked), for: .touchUpInside)
        dateSortButton.addTarget(self, action: #selector(dateSortButtonClicked), for: .touchUpInside)
        highPriceSortButton.addTarget(self, action: #selector(highPriceSortButtonClicked), for: .touchUpInside)
        lowPriceSortButton.addTarget(self, action: #selector(lowPriceSortButtonClicked), for: .touchUpInside)
        
        
        
        /* === 초기 서버 통신 === */
//        callShopingList("samsung", howSort, startNum)   // startNum == 1
    }
    
    /* ===== 서버 통신 함수 ===== */
    func callShopingList(_ query: String, _ sortType: SortCase, _ start: Int) {
        
        // pagination일 때는 기존 배열에 append
        // 새로 검색했거나 정렬 방식 바꿨을 때는 배열 초기화 후 append
        // -> 배열 초기화는 함수 실행시키기 전에 해주는 걸로 한다
        
        if (query == "") {
            // 빈 문자열 입력했을 때 예외처리
        }else {
            ShoppingAPIManager.shared.callShoppingList(query, sortType, start) { value in
//                print(value)
                
                // 새로운 검색을 하는 상황이면 스크롤을 맨 위로 올려준다
                // "새로운 검색을 하는 상황" : startNum == 1
                if (self.startNum == 1) {
                    self.collectionView.setContentOffset(.zero, animated: true)
                    self.data.removeAll()
                }
                
                self.totalNum = value.total
                self.data.append(contentsOf: value.items)
                
                self.collectionView.reloadData()
                
                
            }
        }
    }
    
    /* ===== 데이터 초기화 함수= ===== */
    func initData() {
        startNum = 1
    }
    
    
    /* ===== 현재 서치바의 텍스트 기반으로 새롭게 검색 후 테이블 업데이트까지 =====*/
    func searchNewData() {
        initData()
        
        guard let query = searchController.searchBar.text else { return }
        callShopingList(query, howSort, startNum)
    }
    
    
    
    /* ===== 버튼 addTarget 액션 ===== */
    @objc
    func accuracySortButtonClicked() {
        howSort = .accuracy
        searchNewData()
        changeSortButtonDesign()
    }
    @objc
    func dateSortButtonClicked() {
        howSort = .date
        searchNewData()
        changeSortButtonDesign()
    }
    @objc
    func highPriceSortButtonClicked() {
        howSort = .highPrice
        searchNewData()
        changeSortButtonDesign()
    }
    @objc
    func lowPriceSortButtonClicked() {
        howSort = .lowPrice
        searchNewData()
        changeSortButtonDesign()
    }
    
    
    /* === 정렬 타입에 따라 버튼 디자인 변경 === */
    func changeSortButtonDesign() {
        
        let buttons = [accuracySortButton, dateSortButton, highPriceSortButton, lowPriceSortButton]
        for (index, button) in buttons.enumerated() {
            if let title = button.titleLabel?.text, title == howSort.title {
                buttons[index].backgroundColor = .white
                buttons[index].titleLabel?.textColor = .black
            } else {
                buttons[index].backgroundColor = .clear
                buttons[index].titleLabel?.textColor = .white
            }
        }
    }
    
    
    /* ===== set Configure / Constraints ===== */
    override func setConfigure() {
        super.setConfigure()
        
        
        [accuracySortButton, dateSortButton, highPriceSortButton, lowPriceSortButton].forEach{ item in
            view.addSubview(item)
        }
        view.addSubview(collectionView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        accuracySortButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(12)
        }
        dateSortButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(accuracySortButton.snp.trailing).offset(5)
        }
        highPriceSortButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(dateSortButton.snp.trailing).offset(5)
        }
        lowPriceSortButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(highPriceSortButton.snp.trailing).offset(5)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(accuracySortButton.snp.bottom).offset(10)
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


/* ========== collectionView extension ========== */
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // collectionViewLayoutFlow
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        let spacing: CGFloat = 12
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let size = UIScreen.main.bounds.width - spacing * 3
        layout.itemSize = CGSize(width: size / 2, height: size / 2 + 100)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        return layout
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier, for: indexPath) as? ShoppingCollectionViewCell else { return UICollectionViewCell() }

        
        cell.initialDesignCell(data[indexPath.row])
        
        
        // 좋아요 데이터에 있는지 확인한다
        // 해당 제품의 product id 기준으로 판단. 다른 데이터는 변동 가능성
        var heart = false
        if !(repository.fetch(data[indexPath.row].productID).isEmpty) {
            // 배열이 비어있지 않으면 좋아요 리스트에 있다는 뜻
            heart = true
        }
        cell.checkHeartButton(heart)    // 좋아요 여부
        
        
        cell.heartCallBackMethod = { [weak self] in // weak 키워드 사용 -> self가 nil일 가능성
            
            print("좋아요 버튼이 눌렸습니다")
            let item = self?.data[indexPath.row]

            // 1. 현재 좋아요 목록에 있는지 확인
            // heart
            
            // 1.5. 좋아요 버튼 이미지 토글
            cell.checkHeartButton(!heart)
            
            // 2. 좋아요 목록에서 해제 or 추가
            // 2 - 1. 해제
            // 좋아요가 이미 눌려져 있다 -> 좋아요 리스트에 있다.
            // 리스트에서 그 애를 찾아서 꺼낸 후 (read - filter)
            // delete 함수에 넣는다
            if (heart) {
                if let item, let task = self?.repository.fetch(item.productID).first { // 어차피 하나밖에 없을거긴 한데, 배열 형태에서 좀 바꿔주기 위해 first 써줌
                    
                    self?.repository.deleteItem(task) 
                }
            }
            // 2 - 2. 추가
            else {
                if let item {
                    
                    // (1). task 생성
                    let task = LikesTable(productId: item.productID, mallName: item.mallName, title: item.title, lprice: item.lprice, imageLink: item.image)
                    
                    // 이미지 데이터로 변환
                    //                let group = DispatchGroup()
                    let url = URL(string: item.image)
                    //                group.enter()
                    DispatchQueue.global().async {
                        if let url, let data = try? Data(contentsOf: url) {
                            task.imageData = data
                        }
                        
                        // (2). task 추가 (이미지 데이터 저장이 끝났을 때)
                        // realm에 접근하기 때문에 다시 main
                        DispatchQueue.main.async {
                            self?.repository.createItem(task)
                        }
                        
                        // UI 적으로 화면에 변화가 없는 부분이기 때문에 global에서 async로 돌려도 문제 없다고 판단함
                        //                    group.leave()
                    }
                    //                group.notify(queue: .main) {
                    //                        print("END")
                    //                }
                }
            }
       
            
            
            
            
            
            
            // (3. tableView reload를 할 필요가 없다. 여기 cellForRowAt임)
            
        }
        
        
        return cell;
    }
}

/* ========== collectionView Prefetching extension ========== */
extension SearchViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // pagination
        
        for indexPath in indexPaths {
            if (indexPath.row == data.count - 1) && (startNum < 91) && (indexPath.row < totalNum) {
                
                startNum += 30;
                print("pagination 실행됩니다. 바뀐 startNum : \(startNum)")
                
                guard let query = searchController.searchBar.text else { return }
                callShopingList(query, SortCase.accuracy, startNum)
            }
        }
    }
    
    
}


/* ========== collectionView extension ========== */
extension SearchViewController: UISearchBarDelegate {
    // 실시간x
    // 검색 버튼 눌렀을 때 화면 업데이트
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       searchNewData()
    }
}

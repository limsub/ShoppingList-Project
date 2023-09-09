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
    var searchingWord: String = ""          // 현재 로드된 데이터들의 검색 단어 -> 검색 시에만 업데이트.
    
    /* ========== repository pattern ========== */
    let repository = LikesTableRepository()
    
    /* ========== 인스턴스 생성 ========== */
    let searchController = UISearchController(searchResultsController: nil)
    
    static func makeSortButton(_ type: SortCase) -> UIButton {
        let button = UIButton()
        
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.setTitleColor(.systemGray, for: .normal)
        button.layer.borderWidth = 1
        
        button.setTitle(type.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        
        return button
    }
    
    let accuracySortButton = makeSortButton(SortCase.accuracy)
    let dateSortButton = makeSortButton(SortCase.date)
    let highPriceSortButton = makeSortButton(SortCase.highPrice)
    let lowPriceSortButton = makeSortButton(SortCase.lowPrice)
    
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        
        view.backgroundColor = .systemBackground
        
        view.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier)
        
        view.dataSource = self
        view.delegate = self
        view.prefetchDataSource = self
        
        view.keyboardDismissMode = .onDrag

        return view
    }()
    
    
    
    /* === 정렬 타입에 따라 버튼 디자인 변경 === */
    func changeSortButtonDesign() {
        
        let buttons = [accuracySortButton, dateSortButton, highPriceSortButton, lowPriceSortButton]
        for (index, button) in buttons.enumerated() {
            if let title = button.titleLabel?.text, title == howSort.title {
                buttons[index].backgroundColor = .white
                buttons[index].setTitleColor(.black, for: .normal)
            } else {
                buttons[index].backgroundColor = .clear
                buttons[index].setTitleColor(.systemGray, for: .normal)
            }
        }
        
    }
    
    
    
    /* ========== viewDidLoad ========== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        
        repository.printURL()
        
        view.backgroundColor = .systemBackground
        

        
        
        /* === 네비게이션 아이템 및 서치바 커스텀 === */
        title = "쇼핑 검색"
        
        navigationItem.searchController = searchController              // 서치 컨트롤러 등록
        navigationItem.hidesSearchBarWhenScrolling = false              // 스크롤 시에도 서치바 유지
        
        searchController.hidesNavigationBarDuringPresentation = false   // 네비게이션 타이틀 계속 띄워주기
        searchController.searchBar.delegate = self  // 프로토콜 연결
        searchController.searchBar.searchTextField.backgroundColor = .systemGray6   // 텍스트필드 배경생 지정
        searchController.searchBar.tintColor = .white   // 텍스트필드 커서, 취소 글자 색상 -> 다크모드 대응 필요
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")   // 한글로 "취소" 설정
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "검색어를 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])  // 플레이스홀더 커스텀
        
        navigationController?.navigationBar.backgroundColor = .systemBackground // 네비게이션 바 배경색
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]   // 타이틀 색상
        navigationController?.navigationBar.tintColor = .white
        
        
        /* === 정렬 버튼 디자인 및 addTarget === */
        accuracySortButton.addTarget(self, action: #selector(accuracySortButtonClicked), for: .touchUpInside)
        dateSortButton.addTarget(self, action: #selector(dateSortButtonClicked), for: .touchUpInside)
        highPriceSortButton.addTarget(self, action: #selector(highPriceSortButtonClicked), for: .touchUpInside)
        lowPriceSortButton.addTarget(self, action: #selector(lowPriceSortButtonClicked), for: .touchUpInside)
        
        changeSortButtonDesign()
    }
    
    /* ========== viewWillAppear ========== */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.delegate = self
        
        // 좋아요 창에서 넘어올 때 셀 좋아요 여부를 업데이트 해주기 위해 필요함
        collectionView.reloadData()
    }
    
    
    /* ===== 서버 통신 함수 ===== */
    func callShopingList(_ query: String, _ sortType: SortCase, _ start: Int) {
        
        // case 1 (pagination) : 기존 배열에 새로운 데이터 append
        // case 2 (reload) : 기존 배열 초기화 후 새로운 데이터 append
        
        if (query == "") {
            // 빈 문자열
            // 서치바 상에서 검색이 불가능하기 때문에 들어올 수 없음
        } else {
            ShoppingAPIManager.shared.callShoppingList(query, sortType, start) { value in
//                print(value)
                
                // case 2
                if (self.startNum == 1) {
                    self.collectionView.setContentOffset(.zero, animated: true) // 스크롤 시점 맨 위로 올림
                    self.data.removeAll()   // 배열 초기화
                }
                
                self.totalNum = value.total
                self.data.append(contentsOf: value.items)   // 새로운 데이터 append
                
                self.collectionView.reloadData()
            } showAlertWhenNetworkDisconnected: {
                self.showAlert("네트워크 연결이 끊겼습니다", "목록을 불러올 수 없습니다")
            }
            
            
        }
    }
    
    /* ===== 데이터 초기화 함수= ===== */
    func initData() {
        startNum = 1
    }
    
    
    /* ===== 현재 서치바 텍스트 기반으로 검색 후 테이블 업데이트 ===== */
    // (1). return 키    (2). 정렬 버튼 4개
    func searchNewData() {
        initData()
        
        let query = searchingWord
        
        
        callShopingList(query, howSort, startNum)
    }
    
    func checkAllSpace(_ sender: String) -> Bool {
        let set = CharacterSet.whitespaces
        
        let str = sender.trimmingCharacters(in: set)
        
        return str.isEmpty
    }
    
    
    
    /* ===== 버튼 addTarget 액션 ===== */
    @objc
    func accuracySortButtonClicked() {
        searchController.searchBar.resignFirstResponder()   // 키보드 내림
        
        if NetworkMonitor.shared.isConnected {
            howSort = .accuracy         // 현재 정렬 상태 변경
            searchNewData()             // 검색 진행
            changeSortButtonDesign()    // 버튼 디자인 변경
        } else {
            showAlert("네트워크 연결이 끊겼습니다", "해당 기능을 사용할 수 없습니다")
        }
    }
    @objc
    func dateSortButtonClicked() {
        searchController.searchBar.resignFirstResponder()
        
        if NetworkMonitor.shared.isConnected {
            howSort = .date
            searchNewData()
            changeSortButtonDesign()
        } else {
            showAlert("네트워크 연결이 끊겼습니다", "해당 기능을 사용할 수 없습니다")
        }
    }
    @objc
    func highPriceSortButtonClicked() {
        searchController.searchBar.resignFirstResponder()
        
        if NetworkMonitor.shared.isConnected {
            howSort = .highPrice
            searchNewData()
            changeSortButtonDesign()
        } else {
            showAlert("네트워크 연결이 끊겼습니다", "해당 기능을 사용할 수 없습니다")
        }
    }
    @objc
    func lowPriceSortButtonClicked() {
        searchController.searchBar.resignFirstResponder()
        
        if NetworkMonitor.shared.isConnected {
            howSort = .lowPrice
            searchNewData()
            changeSortButtonDesign()
        } else {
            showAlert("네트워크 연결이 끊겼습니다", "해당 기능을 사용할 수 없습니다")
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
        
        let spacing: CGFloat = 14
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let size = UIScreen.main.bounds.width - spacing * 3
        layout.itemSize = CGSize(width: size / 2, height: size / 2 + 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        return layout
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier, for: indexPath) as? ShoppingCollectionViewCell else { return UICollectionViewCell() }

        
        cell.initialDesignCell(data[indexPath.row], searchingWord)
        
        /* == 좋아요 여부 확인 후 버튼 디자인 === */
        var heart = false
        if !(repository.fetch(data[indexPath.row].productID).isEmpty) {
            heart = true
        }
        cell.checkHeartButton(heart)
        
        
        /* == 좋아요 버튼 콜백함수 정의 === */
        cell.heartCallBackMethod = { [weak self] in // weak 키워드 사용 -> self가 nil일 가능성
            
            
            
            
            let item = self?.data[indexPath.row]

            // 1. 현재 좋아요 목록에 있는지 확인
            // heart
            
            // 1.5. 좋아요 버튼 이미지 토글
            cell.checkHeartButton(!heart)
            
            // 2. 좋아요 목록에서 해제 or 추가
            if (heart) {
                // 2 - 1. 해제
                    // (1). 좋아요 리스트에서 검색
                    // (2). 검색 결과 delete
                    // (3). collectionView reload
                if let item, let task = self?.repository.fetch(item.productID).first {
                    self?.repository.deleteItem(task)
                    self?.collectionView.reloadData()
                }
            }
            else {
                // 네트워크 통신이 끊겼을 경우 -> 이미지를 제외한 값만 디비에 저장 가능
                if (!NetworkMonitor.shared.isConnected) {
                    self?.showAlert("네트워크 연결이 끊겼습니다", "이미지를 제외한 데이터만 저장됩니다")
                }
                
                // 2 - 2. 추가
                    // (1). 현재 데이터 기반으로 new task 생성
                    // (2). 이미지 따로 추가 (imageLink -> 데이터 변환)
                    // (3). new task create
                    // (4). collectionView reload
                if let item {
                    let task = LikesTable(productId: item.productID, mallName: item.mallName, title: item.title, lprice: item.lprice, imageLink: item.image)
                    
                    let url = URL(string: item.image)
                    DispatchQueue.global().async {  // try Data : 동기
                        if let url, let data = try? Data(contentsOf: url) {
                            task.imageData = data
                        }
                        DispatchQueue.main.async {  // realm, UI : main
                            self?.repository.createItem(task)
                            self?.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchController.searchBar.resignFirstResponder()
        
        let item = data[indexPath.row]
        
        // 값 전달 : LikesTable 타입(각종 정보)과 Bool 타입(좋아요 여부)로 넘겨줌
        let task = LikesTable(productId: item.productID, mallName: item.mallName, title: item.title, lprice: item.lprice, imageLink: item.image)
        
        // 좋아요 여부 체크
        var heart = false
        if !(repository.fetch(item.productID).isEmpty) {
            heart = true
        }
        
        // + 이미지 데이터 추가
        let url = URL(string: item.image)
        DispatchQueue.global().async {
            if let url, let data = try? Data(contentsOf: url) {
                task.imageData = data
            }
            
            // 데이터 추가가 완료된 이후, 화면 전환
            // 화면 전환
            DispatchQueue.main.async {
                let vc = WebViewController()
                vc.product = task
                vc.likeOrNot = heart
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        
        

    }
}



/* ========== collectionView Prefetching extension ========== */
extension SearchViewController: UICollectionViewDataSourcePrefetching {
    
    // pagination
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        
        for indexPath in indexPaths {
            // (1). indexPath.row가 현재 로드한 거의 모든 데이터까지 왔을 때
            // (2). startNum 쿼리는 최대 100까지만 가능하기 때문에 maximum 91
            // (3). (거의 무조건이지만) 혹시 현재 인덱스가 검색 가능한 데이터의 총량보다 적을 때
            if (indexPath.row == data.count - 1) && (startNum < 91) && (indexPath.row < totalNum) {
                // startNum : 데이터 시작 위치. 30씩 올려준다
                startNum += 30;
                
                // 데이터를 초기화하는 부분이 아니기 때문에 searchNewData 실행하지 않는다
                callShopingList(searchingWord, howSort, startNum)
            }
            else if (startNum >= 91) {
                // 더 이상 데이터 로드 불가 얼럿
            }
        }
    }
    
    
}


/* ========== searchBar extension ========== */
extension SearchViewController: UISearchBarDelegate {
    // 실시간x
    // 검색 버튼 눌렀을 때 화면 업데이트
    // cancel 버튼 눌러도 기존 화면 유지한다
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchingWord = searchController.searchBar.text ?? ""
        
        if (checkAllSpace(searchingWord)) { return }    // 공백만 있는 문자열은 검색 x
        
        searchNewData()
    }
}


/* ========== tabBar extension ========== */
extension SearchViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let currentIndex = tabBarController.selectedIndex
        let currentVC = tabBarController.viewControllers?[currentIndex]

        if  currentVC != viewController { return true }

        self.collectionView.setContentOffset(.zero, animated: true) // 스크롤 시점 맨 위로

        return false
    }
}

//
//  SearchViewController.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit

final class SearchViewController: BaseViewController {
    
    /* ===== MVVM 적용 ===== */
    let viewModel = SearchViewModel()
    

    /* ========== 컬렉션뷰 데이터 ========== */
//    var data: [Item] = []
//    var startNum: Int = 1   // pagination (1 -> 31 -> 61 -> 91 -> done)
//    var totalNum: Int = 0   // pagination 시 예외처리용
//    var goEndScroll = false // pagination 예외처리용
//    var howSort = SortCase.accuracy    // 정렬 기준. 디폴트 : 정확도
//    var searchingWord: String = ""          // 현재 로드된 데이터들의 검색 단어 -> 검색 시에만 업데이트.
    
    
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
        
        view.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.description())
        
        view.dataSource = self
        view.delegate = self
        view.prefetchDataSource = self
        
        view.keyboardDismissMode = .onDrag

        return view
    }()
    
    let noDataSearched = {
        let view = UIView()
        
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.text = "검색된 데이터가 없습니다"
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
    
    
    /* === 정렬 타입에 따라 버튼 디자인 변경 === */
    private func changeSortButtonDesign(_ type: SortCase) {
        let buttons = [accuracySortButton, dateSortButton, highPriceSortButton, lowPriceSortButton]
        for (index, button) in buttons.enumerated() {
            if let title = button.titleLabel?.text, title == type.title {
                buttons[index].backgroundColor = .labelColor
                buttons[index].setTitleColor(.systemBackground, for: .normal)
            } else {
                buttons[index].backgroundColor = .clear
                buttons[index].setTitleColor(.systemGray, for: .normal)
            }
        }
    }
    
    
    
    /* ========== viewDidLoad ========== */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        binds()
        customNavigation()
        sortButtonCustom()
    }
    
    /* ========== viewDidLoad에 들어가는 애들 ========== */
    /* ===== MVVM 적용 ===== */
    func binds() {
        viewModel.data.bind { _ in
            self.collectionView.reloadData()
        }
        viewModel.startNum.bind { _ in
            self.viewModel.callShopingList {
                self.collectionView.setContentOffset(.zero, animated: true)
            } showAlert: {
                self.showAlert("네트워크 연결이 끊겼습니다", "목록을 불러올 수 없습니다")
            }
        }
        viewModel.howSort.bind { value in
            self.changeSortButtonDesign(value)
        }

    }
    
    /* === 네비게이션 아이템 및 서치바 커스텀 === */
    func customNavigation() {
        title = "쇼핑 검색"
        
        navigationItem.searchController = searchController              // 서치 컨트롤러 등록
        navigationItem.hidesSearchBarWhenScrolling = false              // 스크롤 시에도 서치바 유지
        
        searchController.hidesNavigationBarDuringPresentation = false   // 네비게이션 타이틀 계속 띄워주기
        searchController.searchBar.delegate = self  // 프로토콜 연결
        searchController.searchBar.searchTextField.backgroundColor = .systemGray6   // 텍스트필드 배경생 지정
        searchController.searchBar.tintColor = .labelColor   // 텍스트필드 커서, 취소 글자 색상
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")   // 한글로 "취소" 설정
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "검색어를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])  // 플레이스홀더 커스텀
        
        navigationController?.navigationBar.backgroundColor = .systemBackground // 네비게이션 바 배경색
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.labelColor]   // 타이틀 색상
        navigationController?.navigationBar.tintColor = .labelColor
    }
    
    /* === 정렬 버튼 디자인 및 addTarget === */
    func sortButtonCustom() {
        
        [accuracySortButton, dateSortButton, highPriceSortButton, lowPriceSortButton].forEach { button in
            button.addTarget(self, action: #selector(sortButtonClicked), for: .touchUpInside)
        }
        
        changeSortButtonDesign(viewModel.howSort.value)
    }
    
    
    
    /* ========== viewWillAppear ========== */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.delegate = self
        collectionView.reloadData()
    }
    
    
    /* ===== 현재 서치바 텍스트 기반으로 검색 후 테이블 업데이트 ===== */
    // (1). return 키    (2). 정렬 버튼 4개
    // searchNewData -> initData -> + callShoppingList
    private func searchNewData() {
        viewModel.initData()
    }
    
    
    /* ===== 버튼 addTarget 액션 ===== */
    @objc
    private func sortButtonClicked(_ button: UIButton) {
        
        guard let whatSort = button.whatSort else { return }
        
        searchController.searchBar.resignFirstResponder()   // 키보드 내림
        if NetworkMonitor.shared.isConnected {
            viewModel.howSort.value = whatSort
            searchNewData()             // 검색 진행
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
        view.addSubview(noDataSearched)
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
        
        noDataSearched.snp.makeConstraints { make in
            make.size.equalTo(200)
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


/* ========== collectionView extension ========== */
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        noDataSearched.isHidden = !viewModel.isDataEmpty()
        
        return viewModel.dataCount()
        
//        if (data.count == 0) {
//            noDataSearched.isHidden = false
//        } else {
//            noDataSearched.isHidden = true
//        }
        
//        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingCollectionViewCell.description(), for: indexPath) as? ShoppingCollectionViewCell else { return UICollectionViewCell() }
        
        let item = viewModel.item(indexPath)

        // 기본 디자인
        cell.initialDesignCell(item, viewModel.searchingWord)
//        cell.initialDesignCell(data[indexPath.row], searchingWord)
        
        // 좋아요 버튼 디자인
        var heart = false
        //        if !(repository.fetch(data[indexPath.row].productID).isEmpty) {
        if !(repository.fetch(item.productID).isEmpty) {
            heart = true
        }
        cell.checkHeartButton(heart)
        
        
        /* == 좋아요 버튼 콜백함수 정의 === */
        cell.heartCallBackMethod = { [weak self] in // weak 키워드 사용 -> self가 nil일 가능성
            
//            let item = self?.data[indexPath.row]

            // 1. 현재 좋아요 목록에 있는지 확인
            // heart
            
            // 1.5. 좋아요 버튼 이미지 토글
//            cell.checkHeartButton(!heart)     // 연속으로 좋아요 버튼을 눌렀을 때 중복으로 데이터가 저장되는 것 방지
            
            // 2. 좋아요 목록에서 해제 or 추가
            if (heart) {
                cell.checkHeartButton(!heart)   // 위치 이동
                
                // 2 - 1. 해제
                    // (1). 좋아요 리스트에서 검색
                    // (2). 검색 결과 delete
                    // (3). collectionView reload
                if let task = self?.repository.fetch(item.productID).first {
                    self?.repository.deleteItem(task)
                    self?.collectionView.reloadData()
                }
            }
            else {
                if (cell.heartButton.image(for: .normal) == UIImage(systemName: "heart.fill") ) { return }
                
                cell.checkHeartButton(!heart)   // 위치 이동
                
                // 네트워크 통신이 끊겼을 경우 -> 이미지를 제외한 값만 디비에 저장 가능
                if (!NetworkMonitor.shared.isConnected) {
                    self?.showAlert("네트워크 연결이 끊겼습니다", "이미지를 제외한 데이터만 저장됩니다")
                }
                
                // 2 - 2. 추가
                    // (1). 현재 데이터 기반으로 new task 생성
                    // (2). 이미지 따로 추가 (imageLink -> 데이터 변환)
                    // (3). new task create
                    // (4). collectionView reload
                
                    
                // 주의!! 애초에 데이터를 저장할 때 <b> 태그를 빼고 저장해야 한다!!!
                var title = item.title
                title = title.replacingOccurrences(of: "<b>", with: "")
                title = title.replacingOccurrences(of: "</b>", with: "")
                
                let task = LikesTable(productId: item.productID, mallName: item.mallName, title: title, lprice: item.lprice, imageLink: item.image)
                
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchController.searchBar.resignFirstResponder()
        
        let item = viewModel.item(indexPath)
//        let item = data[indexPath.row]
        
        // 값 전달 : LikesTable 타입(각종 정보)과 Bool 타입(좋아요 여부)로 넘겨줌
        
        // 주의!! 애초에 데이터를 저장할 때 <b> 태그를 빼고 저장해야 한다!!!
        // 결국, liketable 안에는 <b> 태그가 있으면 안돼!!
        var title = item.title
        title = title.replacingOccurrences(of: "<b>", with: "")
        title = title.replacingOccurrences(of: "</b>", with: "")
        
        let task = LikesTable(productId: item.productID, mallName: item.mallName, title: title, lprice: item.lprice, imageLink: item.image)
        
        // 좋아요 여부 체크
        var heart = false
        if !(repository.fetch(item.productID).isEmpty) {
            heart = true
        }
        
        let vc = WebViewController()
        vc.previousVC = self
        vc.product = task
        vc.likeOrNot = heart
        self.navigationController?.pushViewController(vc, animated: true)
        
        // + 이미지 데이터 추가
        let url = URL(string: item.image)
        DispatchQueue.global().async {
            if let url, let data = try? Data(contentsOf: url) {
                task.imageData = data
                vc.newProduct?.imageData = data // 실질적으로 사용하는 데이터는 newProduct이기 때문에 예외적으로 이미지 데이터만 직접 전달한다
            }
        }
    }
}



/* ========== collectionView Prefetching extension ========== */
extension SearchViewController: UICollectionViewDataSourcePrefetching {
    
    // pagination
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            if viewModel.paginationInPrefetchPossible(indexPath) {
                if (NetworkMonitor.shared.isConnected) {
                    viewModel.plusData()
                } else {
                    viewModel.goEndScroll = true
                    showAlert("네트워크 연결이 끊겼습니다", "데이터를 불러올 수 없습니다")
                }
            }
            else if viewModel.isEndPagination(indexPath) {
                 showAlert("모든 데이터를 불렀습니다", "더 이상 불러올 수 없습니다")
            }
        }
    }
}

extension SearchViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if viewModel.paginationInScrollViewPossible(scrollView.contentSize, scrollView.contentOffset) {
            print("pagination (scroll) 실행")
            viewModel.plusData()
            viewModel.goEndScroll = false // 네트워크 통신 때문인지 contentSize.height 다시 커지는 시점이 이 함수가 다시 실행되는 것보다 늦어서, 얘가 연속해서 계속 실행될 수 있는 문제점
        }
    }
}


/* ========== searchBar extension ========== */
extension SearchViewController: UISearchBarDelegate {
    // 실시간x
    // 검색 버튼 눌렀을 때 화면 업데이트
    // cancel 버튼 눌러도 기존 화면 유지한다
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let currentSearcing = searchController.searchBar.text ?? ""
        
        if (checkAllSpace(currentSearcing)) {
            showAlert("공백으로만 이루어진 단어는 검색할 수 없습니다", "검색어가 업데이트 되지 않습니다")
            return
        }
        
        if (!NetworkMonitor.shared.isConnected) {
            showAlert("네트워크 연결이 끊겼습니다", "목록을 불러올 수 없습니다")
            return
        }
        
        viewModel.searchingWord = currentSearcing
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

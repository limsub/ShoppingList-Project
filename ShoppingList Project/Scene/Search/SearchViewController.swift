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
    
    /* ========== 인스턴스 생성 ========== */
    let searchController = UISearchController(searchResultsController: nil)
    
    static func makeSortButton(_ name: String) -> UIButton {
        let button = UIButton()
        
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        
        // iOS 13에서 되냐 이거
        button.setTitle(name, for: .normal)
        
        return button
    }
    
    let accuracySortButton = makeSortButton("정확도")
    let dateSortButton = makeSortButton("날짜순")
    let highPriceSortButton = makeSortButton("가격높은순")
    let lowPriceSortButton = makeSortButton("가격낮은순")
    
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        
        view.backgroundColor = .blue
        
        view.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier)
        
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    
    /* ========== viewDidLoad ========== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
        
        /* === 네비게이션 아이템 및 서치바 커스텀 === */
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = false   // 네비게이션 타이틀 계속 띄워주기
        navigationItem.hidesSearchBarWhenScrolling = false              // 스크롤 시에도 서치바 유지
        title = "검색 창"
        searchController.searchBar.delegate = self
        
        
        
        /* === 정렬 버튼 addTarget === */
        accuracySortButton.addTarget(self, action: #selector(accuracySortButtonClicked), for: .touchUpInside)
        dateSortButton.addTarget(self, action: #selector(dateSortButtonClicked), for: .touchUpInside)
        highPriceSortButton.addTarget(self, action: #selector(highPriceSortButtonClicked), for: .touchUpInside)
        lowPriceSortButton.addTarget(self, action: #selector(lowPriceSortButtonClicked), for: .touchUpInside)
        
        
        
        /* === 서버 통신 테스트 === */
        callShopingList("apple")
    }
    
    /* ===== 서버 통신 함수 ===== */
    func callShopingList(_ query: String) {
        
        if (query == "") {
            // 빈 문자열 입력했을 때 예외처리
        }else {
            ShoppingAPIManager.shared.callShoppingList(query) { value in
                print(value)
                
                self.data = value.items
                self.collectionView.reloadData()
            }
        }
    }
    
    
    
    /* ===== 버튼 addTarget 액션 ===== */
    @objc
    func accuracySortButtonClicked() {
        collectionView.setContentOffset(.zero, animated: true)
    }
    @objc
    func dateSortButtonClicked() {
        collectionView.setContentOffset(.zero, animated: true)
    }
    @objc
    func highPriceSortButtonClicked() {
        collectionView.setContentOffset(.zero, animated: true)
    }
    @objc
    func lowPriceSortButtonClicked() {
        collectionView.setContentOffset(.zero, animated: true)
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
        cell.checkHeartButton(false)    // 좋아요 여부
        
        return cell;
    }
}


/* ========== collectionView extension ========== */
extension SearchViewController: UISearchBarDelegate {
    // 실시간x
    // 검색 버튼 눌렀을 때 화면 업데이트
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        
        callShopingList(query)
    }
}

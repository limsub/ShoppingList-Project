//
//  LikeViewController.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit
import RealmSwift

// 좋아요 창
// 인스턴스
    // 서치바
    // 컬렉션뷰

class LikeViewController: BaseViewController {
    
    /* ========== repository pattern ========== */
    let repository = LikesTableRepository()
    var tasks: Results<LikesTable>?
    
    /* ========== 인스턴스 생성 ========== */
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        
        view.backgroundColor = .red
        
        view.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier)
        
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    
    
    /* ========== viewDidLoad ========== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tasks = repository.fetch()
        
        
        view.backgroundColor = .red
        
        /* === 네비게이션 아이템 커스텀 === */
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        title = "좋아요 창"
        searchController.searchBar.delegate = self
    
    }
    
    /* ========== viewWillAppear ========== */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(tasks)
        
        collectionView.reloadData()
    }
    
    /* ===== set Configure / set Constraints ===== */
    override func setConfigure() {
        super.setConfigure()
        
        view.addSubview(collectionView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


/* ========== collectionView extension ========== */
extension LikeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        guard let tasks = tasks else { return 0 }
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        print(#function)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier, for: indexPath) as? ShoppingCollectionViewCell else { return UICollectionViewCell() }
        
        guard let tasks = tasks else { return cell }
        
        cell.initialDesignCellForLikesTable(tasks[indexPath.row])
        
        
        // 좋아요 해제 기능
        // 여기 화면에 있으면 무조건 좋아요가 눌린 상태
        cell.heartCallBackMethod = { [weak self] in
            print("좋아요 화면 : 좋아요가 해제됩니다")
            
            let item = tasks[indexPath.row]
            
            self?.repository.deleteItem(item)
            self?.collectionView.reloadData()
        }
        
        return cell;
    }
    
}

/* ========== searchBar extension ========== */
extension LikeViewController: UISearchBarDelegate {
    
    /* ===== 현재 서치바의 텍스트 기반으로 새롭게 검색 후 테이블 업데이트까지 =====*/
    func searchNewData() {
        guard let txt = searchController.searchBar.text else { return }
        
        tasks = (txt.count == 0) ? repository.fetch() : repository.search(txt)
        
        collectionView.reloadData()
    }
    
    // 실시간 검색
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchNewData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchNewData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchNewData()
    }
    
}

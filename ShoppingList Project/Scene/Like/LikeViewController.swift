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
        
        view.backgroundColor = .systemBackground
        
        view.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier)
        
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    
    
    /* ========== viewDidLoad ========== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 데이터 불러오기
        tasks = repository.fetch()
        
        
        view.backgroundColor = .systemBackground
        
        /* === 네비게이션 아이템 및 서치바 커스텀 === */
        title = "좋아요 목록"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.backgroundColor = .systemGray6
        searchController.searchBar.tintColor = .white
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "검색어를 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    }
    
    /* ========== viewWillAppear ========== */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        let spacing: CGFloat = 14
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let size = UIScreen.main.bounds.width - spacing * 3
        layout.itemSize = CGSize(width: size / 2, height: size / 2 + 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        return layout
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tasks = tasks else { return 0 }
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingCollectionViewCell.reuseIdentifier, for: indexPath) as? ShoppingCollectionViewCell else { return UICollectionViewCell() }
        
        guard let tasks = tasks else { return cell }
        
        var searchWord = searchController.searchBar.text ?? ""
        
        if (checkAllSpace(searchWord)) { searchWord = "" }
        
        cell.initialDesignCellForLikesTable(tasks[indexPath.row], searchWord)
        
        
        // 좋아요 해제 기능
        cell.heartCallBackMethod = { [weak self] in
            print("좋아요 화면 : 좋아요가 해제됩니다")
            
            let item = tasks[indexPath.row]
            
            self?.repository.deleteItem(item)
            self?.collectionView.reloadData()
        }
        
        return cell;
    }
    
    func checkAllSpace(_ sender: String) -> Bool {
        let set = CharacterSet.whitespaces
        
        let str = sender.trimmingCharacters(in: set)
        
        return str.isEmpty
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let task = tasks?[indexPath.row]
        
        let vc = WebViewController()
        vc.product = task
        vc.likeOrNot = true
        navigationController?.pushViewController(vc, animated: true)
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

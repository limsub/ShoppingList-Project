//
//  ShoppingCollectionViewCell.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit
import Kingfisher

protocol ShoppingListCell {
    func initialDesignCell(_ sender: Item, _ searchWord: String)    // Item 타입이 들어올 때
    func initialDesignCellForLikesTable(_ sender: LikesTable, _ searchWord: String)  // LikesTable 타입이 들어올 때
}


class ShoppingCollectionViewCell: BaseCollectionViewCell, ShoppingListCell {
    
    /* ========== 인스턴스 생성 ========== */
    let posterImageView = {
        let view = UIImageView()
        
        view.backgroundColor = .systemBackground
        
        view.tintColor = .lightGray
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    let mallNameLabel = {
        let label = UILabel()
        
        label.text = ""
        label.numberOfLines = 1
        
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    let titleLabel = {
        let label = UILabel()
        
        label.text = ""
        label.numberOfLines = 2
        
        label.textColor = .labelColor
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    
    let priceLabel = {
        let label = UILabel()
        
        label.text = ""
        label.numberOfLines = 1
        
        label.textColor = .labelColor
        label.font = .boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    lazy var heartButton = {
        let button = UIButton()
        
        button.backgroundColor = .labelColor
        
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemBackground
        
        button.clipsToBounds = true
        button.layer.cornerRadius = 18
        
        button.addTarget(self, action: #selector(heartButtonClicked), for: .touchUpInside)
        
        return button
    }()
    
    let noImageView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "no image"
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .lightGray
        
        view.addSubview(label)
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(50)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
        
        return view
    }()
    
    
    /* ========== 좋아요 버튼 클로저 ========== */
    var heartCallBackMethod: ( () -> Void )?
    
    
    /* ========== 좋아요 버튼 클릭 함수 ========== */
    @objc
    private func heartButtonClicked() {
        if let closure = heartCallBackMethod {
            closure()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.font = .systemFont(ofSize: 13)
    }
    
    /* ========== 셀 디자인 함수 ========== */
    // 초기 디자인
    func initialDesignCell(_ sender: Item, _ searchWord: String) {
        
        let url = URL(string: sender.image)
        posterImageView.kf.setImage(with: url)  // 여기가 네트워크 통신
        posterImageView.contentMode = .scaleAspectFill
        
        // 기본 이미지로 지정
        if !NetworkMonitor.shared.isConnected && (posterImageView.image == UIImage(systemName: "photo") || posterImageView.image == nil)  {   // 이미 다운이 완료된 이미지는 살려주기 위함
            posterImageView.image = UIImage(systemName: "photo")
            posterImageView.contentMode = .scaleAspectFit
        }
        
        mallNameLabel.text = "[\(sender.mallName)]"
        titleLabel.removeTag(sender.title)  // <b> 태그 지우고 title로 설정
        titleLabel.makeBoldWord(sender.title, searchWord) // 검색한 단어 bold 폰트로 변경
        priceLabel.makePriceFormat(sender.lprice)
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    func initialDesignCellForLikesTable(_ sender: LikesTable, _ searchWord: String) {
        if let imageData = sender.imageData {
            posterImageView.image = UIImage(data: imageData)
            posterImageView.contentMode = .scaleAspectFill
        } else {
            posterImageView.image = UIImage(systemName: "photo")
            posterImageView.contentMode = .scaleAspectFit
        }
        
        mallNameLabel.text = "[\(sender.mallName)]"
        titleLabel.text = sender.title
        titleLabel.makeBoldWord(sender.title, searchWord)
        priceLabel.makePriceFormat(sender.lprice)
        
        heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    }
    
    // 좋아요 버튼 체크
    func checkHeartButton(_ sender: Bool) {
        heartButton.setImage(
            UIImage(systemName: (sender) ? "heart.fill" : "heart"),
            for: .normal
        )
    }
    
    
    /* ========== set Configure / Constraints ========== */
    override func setConfigure() {
        super.setConfigure()
        
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(mallNameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(heartButton)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        posterImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(posterImageView.snp.width)
        }
        
        mallNameLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView).inset(5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mallNameLabel.snp.bottom).offset(2)
            make.horizontalEdges.equalTo(contentView).inset(5)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.horizontalEdges.equalTo(contentView).inset(5)
            make.height.equalTo(20)
        }
        
        heartButton.snp.makeConstraints { make in
            make.bottom.equalTo(posterImageView).inset(6)
            make.trailing.equalTo(posterImageView).inset(6) // 두 개 합칠 수 있지 않을까?
            
            make.size.equalTo(36)   // 수치 조절 필요
        }
    }
}

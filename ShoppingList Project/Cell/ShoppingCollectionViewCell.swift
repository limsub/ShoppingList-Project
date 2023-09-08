//
//  ShoppingCollectionViewCell.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit
import Kingfisher

class ShoppingCollectionViewCell: BaseCollectionViewCell {
    
    /* ========== 인스턴스 생성 ========== */
    let posterImageView = {
        let view = UIImageView()
        
        view.backgroundColor = .yellow
        
        return view
    }()
    
    let mallNameLabel = {
        let label = UILabel()
        
        label.text = "몰 네임 몰 네임 몰 네임 몰 네임몰 네임 몰 네임"
        label.numberOfLines = 1
        
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    let titleLabel = {
        let label = UILabel()
        
        label.text = "물건 이름물건 이름물건 이름물건 이름물건 이름물건 이름물건 이름"
        label.numberOfLines = 2
        
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    
    let priceLabel = {
        let label = UILabel()
        
        label.text = "물건 가격물건 가격물건 가격물건 가격물건 가격물건 가격물건 가격물건 가격"
        label.numberOfLines = 1
        
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 15)
        
        return label
    }()
    
    lazy var heartButton = {
        let button = UIButton()
        
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        
        button.addTarget(self, action: #selector(heartButtonClicked), for: .touchUpInside)
        
        return button
    }()
    
    
    /* ========== 좋아요 버튼 클로저 ========== */
    var heartCallBackMethod: ( () -> Void )?
    
    /* ========== 좋아요 버튼 클릭 함수 ========== */
    @objc
    func heartButtonClicked() {
        if let closure = heartCallBackMethod {
            closure()
        }
    }
    
    /* ========== 셀 디자인 함수 ========== */
    // 초기 디자인
    func initialDesignCell(_ sender: Item) {
        
        let url = URL(string: sender.image)
        posterImageView.kf.setImage(with: url)
        
        mallNameLabel.text = sender.mallName
        titleLabel.text = sender.title
        priceLabel.text = sender.lprice // 3개 단위로 쉼표 찍어주기 -> 함수 만들기
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    // 좋아요 버튼 체크 (or 토글)
    // true -> fill / false -> NOT fill
    func checkHeartButton(_ sender: Bool) {
        heartButton.setImage(
            UIImage(systemName: (sender) ? "heart.fill" : "heart"),
            for: .normal
        )
    }
    
    // 가격 쉼표 찍어주는 함수 (세자리마다)
    func makeComma(_ sender: String) -> String {
    
        return ""
    }
    
    /* ========== set Configure / Constraints ========== */
    override func setConfigure() {
        super.setConfigure()
        
        contentView.backgroundColor = .black
        
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
            make.top.equalTo(posterImageView.snp.bottom).offset(5)  // 수치 조절 필요
            make.horizontalEdges.equalTo(contentView).inset(5)
            // 일단 레이블이라 높이 생략. 나중에 잡아주기
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mallNameLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView).inset(5)
            // 일단 레이블이라 높이 생략. 나중에 잡아주기
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView).inset(5)
            make.height.equalTo(20)
            // 일단 레이블이라 높이 생략. 나중에 잡아주기
        }
        
        heartButton.snp.makeConstraints { make in
            make.bottom.equalTo(posterImageView).inset(5)
            make.trailing.equalTo(posterImageView).inset(5) // 두 개 합칠 수 있지 않을까?
            
            make.size.equalTo(50)   // 수치 조절 필요
        }
    }
}

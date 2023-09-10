//
//  Alert.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/09.
//

import UIKit

extension UIViewController {
    // 얼럿
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
    
    // 네비게이션 타이틀
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
    
    // 공백으로만 이루어진 문자열인지 확인
    func checkAllSpace(_ sender: String) -> Bool {
        let set = CharacterSet.whitespaces
        
        let str = sender.trimmingCharacters(in: set)
        
        return str.isEmpty
    }
    
    // 셀 레이아웃
    func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        let spacing: CGFloat = 14
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let size = UIScreen.main.bounds.width - spacing * 3
        layout.itemSize = CGSize(width: size / 2, height: size / 2 + 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        return layout
    }
}

//
//  UILabel.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/09.
//

import UIKit



extension UILabel {
    
    // 가격 쉼표 처리
    func makePriceFormat(_ sender: String) {
        
        // 1. 세 자리마다 쉼표 처리
        let str = String(sender.reversed())
        var result = ""
        var count = 0
        
        for char in str {
            if count == 3 {
                result.append(",")
                count = 0
            }
            result.append(char)
            count += 1
        }
        
        self.text = String(result.reversed())
        
        // 2. 길이 넘어가면 폰트 조정
        if result.count > 14 {
            self.font = .boldSystemFont(ofSize: 15)
        }
    }
    
    
    // 검색 문자열 볼드 처리
    func makeBoldWord(_ fullText: String, _ searchWord: String) {
        let fullText = self.text ?? ""
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        
        let target = searchWord
        
        var ranges: [NSRange] = []
        var range = NSRange(location: 0, length: fullText.count)
        
        while (true) {
            range = (fullText as NSString).range(of: target, options: [.caseInsensitive], range: range)
            ranges.append(range)
            
            if (range.location == NSNotFound) {
                break
            }
                
            let start = range.location + range.length
            range = NSRange(location: start, length: fullText.count - start)
        }
        
        ranges.forEach { item in
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: item)
        }
        
        self.attributedText = attributedString
    }
    
    
    // b 태그 포함 문자열 리턴 함수
    func tagString(_ sender: String) -> String {
        guard let start = sender.range(of: "<b>"),
              let end = sender.range(of: "</b>") else { return ""}
        
        let ans = sender[start.lowerBound..<end.upperBound]
        
        return String(ans)
    }
    

    // b 태그 제거 함수
    func removeTag(_ sender: String) {
        
        var ans = sender.replacingOccurrences(of: "<b>", with: "")
        ans = ans.replacingOccurrences(of: "</b>", with: "")
        
        self.text = ans
    }
}

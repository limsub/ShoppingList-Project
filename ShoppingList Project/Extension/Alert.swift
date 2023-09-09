//
//  Alert.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/09.
//

import UIKit

extension UIViewController {
    
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
    
}

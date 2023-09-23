//
//  Observable.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/23.
//

import Foundation

class Observable<T> {
    
    private var listener: ( (T) -> Void )?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void ) {
        print("바인드")
        self.listener = closure
    }
    
}

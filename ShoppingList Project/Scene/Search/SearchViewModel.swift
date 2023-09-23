//
//  SearchViewModel.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/22.
//

import Foundation


class SearchViewModel {
    
    // 인스턴스
    var data: Observable<[Item]> = Observable([])   // Observable 업데이트
    var startNum: Observable<Int> = Observable(1)   // Observable 업데이트
    var totalNum: Int = 0
    var goEndScroll = false
    var howSort = Observable(SortCase.accuracy)     // Observable 업데이트
    var searchingWord: String = ""
    
    
    // 메서드
    
    /* ===== 서버 통신 함수 ===== */
    func callShopingList(initScroll: @escaping () -> Void,
                         showAlert: @escaping () -> Void) {
        
        // case 1 (pagination) : 기존 배열에 새로운 데이터 append
        // case 2 (reload) : 기존 배열 초기화 후 새로운 데이터 append
        
        if (searchingWord == "") {
        } else {
            ShoppingAPIManager.shared.callShoppingList(searchingWord, howSort.value, startNum.value) { value in
                
                var tmpData = self.data.value   // 임시값
                if (self.startNum.value == 1) {
                    initScroll()
                    tmpData.removeAll()
                }
                tmpData.append(contentsOf: value.items)
                self.data.value = tmpData
                
            } showAlertWhenNetworkDisconnected: {
                showAlert()
            }
        }
    }
    
    /* ===== startNum 함수 ===== */
    func initData() {
        startNum.value = 1
    }
    func plusData() {
        startNum.value += 30
    }
    

    
    /* ===== numberOfItemsInSection ===== */
    func isDataEmpty() -> Bool {
        if data.value.count == 0 {
            return true
        } else {
            return false
        }
    }
    func dataCount() -> Int {
        return data.value.count
    }
    
    
    /* ===== cellForItemAt ===== */
    func item(_ indexPath: IndexPath) -> Item {
        return data.value[indexPath.row]
    }
    
    
    /* ===== pagination ===== */
    func paginationInPrefetchPossible(_ indexPath: IndexPath) -> Bool {
        if indexPath.row == data.value.count - 1  && startNum.value < 991
            && indexPath.row < totalNum && startNum.value < totalNum - 30 {
            return true
        } else {
            return false
        }
    }
    func isEndPagination(_ indexPath: IndexPath) -> Bool {
        if indexPath.row == data.value.count - 1 && startNum.value >= 991 {
            return true
        } else {
            return false
        }
    }
    func paginationInScrollViewPossible(_ contentSize: CGSize, _ contentOffset: CGPoint) -> Bool {
        if contentSize.height - contentOffset.y < 700 && startNum.value < 991 && goEndScroll && startNum.value < totalNum - 30 && NetworkMonitor.shared.isConnected {
            return true
        } else {
            return false
        }
    }
    
}

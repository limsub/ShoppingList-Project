//
//  LikeViewModel.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/23.
//

import Foundation
import RealmSwift


final class LikeViewModel {
    
    let repository = LikesTableRepository()
    
    lazy var tasks: Observable<Results<LikesTable>> = Observable(repository.fetch())
    
    var searchingText = Observable("")
    
    
    /* === 데이터 불러오기 (fetch) === */
    func fetchTasks() {
        tasks.value = repository.fetch()
    }
    
    
    /* ===== numberOfItemsInSection ===== */
    func isTasksEmpty() -> Bool {
        if tasks.value.count == 0 {
            return true
        } else {
            return false
        }
    }
    func tasksCount() -> Int {
        return tasks.value.count
    }
    
    /* ===== Tasks Item ===== */
    func itemInTasks(_ indexPath: IndexPath) -> LikesTable {
        return tasks.value[indexPath.row]
    }
    
    /* === search text and update tasks === */
    func updateTasks() {
        tasks.value = (searchingText.value.count == 0) ? repository.fetch() : repository.search(searchingText.value)
    }
    
    
    
}

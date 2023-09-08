//
//  LikesTableRepository.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/08.
//

import UIKit
import RealmSwift


protocol LikesTableRepositoryType: AnyObject {
    // Create
    func createItem(_ item: LikesTable)
    
    // Read
    func fetch() -> Results<LikesTable>
    // 검색해서 읽어오는 걸 어디서 구현할까
    
    // Update
    func updateItem(_ value: [String: Any])
    
    // Delete
    func deleteItem(_ item: LikesTable)
}

class LikesTableRepository: LikesTableRepositoryType {
    
    private let realm = try! Realm()
    
    // Create
    func createItem(_ item: LikesTable) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Create Error : ", error)
        }
    }
    
    
    // Read
    func fetch() -> Results<LikesTable> {
        let data = realm.objects(LikesTable.self)
        return data
    }
    func fetch(_ productId: String) -> Results<LikesTable> {
        let data = realm.objects(LikesTable.self).where {
            $0.productId == productId
        }
        return data
    }
    
    
    // Update
    func updateItem(_ value: [String : Any]) {
        do {
            try realm.write {
                realm.create(LikesTable.self, value: value, update: .modified)
            }
        } catch {
            print("Update Error : ", error)
        }
    }
    
    
    // Delete
    func deleteItem(_ item: LikesTable) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Delete Error : ", error)
        }
    }
    
    
    // Print fileURL
    func printURL() {
        print(realm.configuration.fileURL!)
    }
    
    // Check schema version
    func checkSchemaVersion() {
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema Version : ", version)
        } catch {
            print("Version Check Error : ", error)
        }
    }
}

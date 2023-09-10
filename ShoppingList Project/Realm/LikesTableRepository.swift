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
    func fetch(_ productId: String) -> Results<LikesTable>
    func search(_ title: String) -> Results<LikesTable>
    
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
        let data = realm.objects(LikesTable.self).sorted(byKeyPath: "time", ascending: false)
        return data
    }
    func fetch(_ productId: String) -> Results<LikesTable> {
        let data = realm.objects(LikesTable.self).where {
            $0.productId == productId
        }
        return data
    }
    func search(_ title: String) -> Results<LikesTable> {
        let data = realm.objects(LikesTable.self).sorted(byKeyPath: "time", ascending: false).where {
            $0.title.contains(title, options: .caseInsensitive)
        }
        return data
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

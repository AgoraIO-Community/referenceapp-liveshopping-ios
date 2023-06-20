//
//  FirebaseConnect.swift
//  LiveCommerce
//
//  Created by Max Cobb on 07/03/2023.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabaseSwift
import FirebaseDatabase

struct FirebaseConnect {
    static var shared = FirebaseConnect()
    let storage: Storage
    let ref: DatabaseReference
    private init() {
        FirebaseApp.configure()
        storage = Storage.storage()
        ref = Database.database(url: AppKeys.databaseURL).reference()
    }

    func fetchShow(with id: String) async -> LiveShow? {
        let recShow = try? await self.ref.child("shows").child(id).getData()
        let decoder = JSONDecoder()
        guard let showDict = recShow?.value as? [String: Any] else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: showDict, options: []) else {
            return nil
        }
        do {
            let liveShow = try decoder.decode(LiveShow.self, from: data)
            return liveShow
        } catch {
            print("Failed to decode store object:", error)
        }
        return nil
    }

    func decrementStock(of productId: String) async throws -> Bool {
        guard let product: Product = await self.getObject(
            from: "products", id: productId
        ), product.stock > 0 else { return false }
        try await self.ref.child("products").child(productId).child("stock").setValue(product.stock - 1)
        return true
    }

    func getStrings(from childPath: String) async -> [String] {
        do {
            return try await self.ref.child(childPath).getData().value as? [String] ?? []
        } catch {
            print("could not get data: \(error)")
        }
        return []
    }

    func getObjects<T: Codable>(from childPath: String) async -> [T] {
        var recObjects: DataSnapshot?
        do {
            recObjects = try await self.ref.child(childPath).getData()
        } catch {
            print("could not get data: \(error)")
        }
        var objs: [T] = []
        guard let objsDict = recObjects?.value as? [String: Any] else {
            print("No objects found at path \(childPath)")
            return []
        }
        let decoder = JSONDecoder()
        for (_, objVal) in objsDict {
            guard let objDict = objVal as? [String: Any] else { continue }

            guard let data = try? JSONSerialization.data(withJSONObject: objDict, options: []) else {
                continue
            }
            do {
                let obj = try decoder.decode(T.self, from: data)
                objs.append(obj)
            } catch {
                print("Failed to decode object:", error)
            }
        }
        return objs
    }

    func getObject<T: Codable>(from childPath: String, id: String) async -> T? {
        let recStores = try? await self.ref.child(childPath).child(id).getData()
        guard let storeDict = recStores?.value as? [String: Any] else {
            print("Object not found")
            return nil
        }
        let decoder = JSONDecoder()

        guard let data = try? JSONSerialization.data(withJSONObject: storeDict, options: []) else {
            return nil
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Failed to decode store object:", error)
        }
        return nil
    }

    func getObjects<T: Codable>(from childPath: String, ids: [String]) async -> [T] {
        let foo = await withTaskGroup(of: T?.self, body: { group in
            var products = [T]()
            products.reserveCapacity(ids.count)

            for id in ids {
                group.addTask {
                    await self.getObject(from: childPath, id: id)
                }
            }
            for await memb in group {
                if let memb { products.append(memb) }
            }
            return products
        })
        return foo
    }

    @discardableResult
    func uploadDatabaseObject(_ obj: (any Codable & Identifiable), in path: String) async throws -> DatabaseReference {
        // add all Products
        let encoder = JSONEncoder()

        let myProduct = self.ref.child(path).child(obj.id as! String)

        guard let data = try? encoder.encode(obj) else {
            fatalError("Failed to encode object")
        }

        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            fatalError("Failed to convert data to dictionary")
        }
        return try await myProduct.setValue(dictionary)
    }

    func appendDatabaseObject(_ newItem: String, to childPath: String) async throws {
        let root = self.ref.child(childPath)
        var items = await self.getStrings(from: childPath)
        items.append(newItem)
        try await root.setValue(items)
    }

    func uploadNewArrayVal(newShow: (any Codable & Identifiable), in childPath: String, store: String) async throws -> DatabaseReference {
        try await self.uploadDatabaseObject(newShow, in: childPath)
        let showsRoot = self.ref.child("stores").child(store).child(childPath)
        let currentShows = try? await showsRoot.getData()
        var showsArr = currentShows?.value as? [String] ?? [String]()
        showsArr.append(newShow.id as! String)
        return try await showsRoot.setValue(showsArr)
    }

    func deleteStoreSub(in store: String, ids: [String], childPath: String) async {
        let dictToRemove = Dictionary(uniqueKeysWithValues: ids.map { ($0, Any?.none) })
        _ = try? await self.ref.child(childPath).updateChildValues(dictToRemove as [AnyHashable: Any])
        let productsRoot = self.ref.child("stores").child(store).child(childPath)
        let currentShows = try? await productsRoot.getData()
        var showsArr = currentShows?.value as? [String] ?? [String]()
        showsArr = showsArr.filter { !dictToRemove.keys.contains($0) }
        _ = try? await productsRoot.setValue(showsArr)
    }

    func uploadImage(image: Data) async throws -> String? {

        // Create a root reference
        let storageRef = storage.reference()

        // Create a reference to image location
        let mountainImagesRef = storageRef.child("images/\(UUID().uuidString)")

        guard let metaData = try? await mountainImagesRef.putDataAsync(image) else {
            return nil
        }

        return metaData.path
    }
}

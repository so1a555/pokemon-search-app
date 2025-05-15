import Foundation
import SwiftUI

class FavoriteManager {
    static let key = "Favorites"
    
    // ユーザーのデフォルトからお気に入りリストを読み込む
    static func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
    
    // お気に入りリストを保存
    static func save(_ list: [String]) {
        UserDefaults.standard.set(list, forKey: key)
    }
    
    // 指定したポケモン名をお気に入りに追加 or 削除し、結果のリストを返す
    static func toggle(_ name: String) -> [String] {
        var current = load()
        if let index = current.firstIndex(of: name) {
            current.remove(at: index)
        } else {
            current.append(name)
        }
        save(current)
        return current
    }
}


struct FavoriteListView: View {
    let favorites: [String]
    var onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            List(favorites, id: \.self) { name in
                Button(action: {
                    onSelect(name)
                }) {
                    Text(name)
                }
            }
            .navigationTitle("お気に入りポケモン")
        }
    }
}



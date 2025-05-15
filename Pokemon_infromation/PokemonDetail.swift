import Foundation



// ポケモンの種族情報（日本語名・説明テキストなど）を保持する構造体
struct SpeciesInfo: Codable {
    struct NameEntry: Codable {
        let name: String
        let language: Language
    }
    
    
// フレーバーテキスト（説明文）とその言語
struct FlavorText: Codable {
    let flavorText: String
    let language: Language

    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
    }
}

// 言語情報構造体（例: "ja" や "en"）
struct Language: Codable {
    let name: String
}

let names: [NameEntry]
let flavorTextEntries: [FlavorText]

enum CodingKeys: String, CodingKey {
    case names
    case flavorTextEntries = "flavor_text_entries"
    }
}

// ポケモンの詳細情報（画像・タイプ・身長・体重など）を保持する構造体
struct PokemonDetail: Codable {
    struct Sprite: Codable {
        let frontDefault: URL?

        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
    
    // タイプ情報
    struct TypeEntry: Codable {
        let type: TypeName
    }
    
    // タイプの名前（英語）を保持
    struct TypeName: Codable {
        let name: String
    }

    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprite
    let types: [TypeEntry]
}



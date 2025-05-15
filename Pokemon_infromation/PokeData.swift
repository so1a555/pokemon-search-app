import Foundation

class PokeData: ObservableObject {
    @Published var nameMap: [String: String] = [:]

    struct ListResponse: Codable {
        let results: [BasicPokemon]
    }

    struct BasicPokemon: Codable {
        let name: String
        let url: String
    }

    struct SpeciesResponse: Codable {
        let names: [NameEntry]

        struct NameEntry: Codable {
            let name: String
            let language: Language

            struct Language: Codable {
                let name: String
            }
        }
    }
    
    // 日本語名と英語名を対応させる辞書（nameMap）を生成
    func generateNameMap() async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1000") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ListResponse.self, from: data)

            await withTaskGroup(of: (String, String)?.self) { group in
                for basic in decoded.results {
                    if let id = extractID(from: basic.url) {
                        group.addTask {
                            do {
                                let speciesURL = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(id)")!
                                let (speciesData, _) = try await URLSession.shared.data(from: speciesURL)
                                let species = try JSONDecoder().decode(SpeciesResponse.self, from: speciesData)

                                if let jp = species.names.first(where: { $0.language.name == "ja-Hrkt" })?.name {
                                    return (jp, basic.name)
                                }
                            } catch {}
                            return nil
                        }
                    }
                }

                for await result in group {
                    if let (jp, en) = result {
                        DispatchQueue.main.async {
                            self.nameMap[jp] = en
                        }
                    }
                }
            }
        } catch {
            print("名前マップ生成失敗: \(error.localizedDescription)")
        }
    }
    // ポケモンのURLからIDを抽出する（末尾の数字）
    private func extractID(from url: String) -> Int? {
        guard let last = url.split(separator: "/").last,
              let id = Int(last) else { return nil }
        return id
    }
}

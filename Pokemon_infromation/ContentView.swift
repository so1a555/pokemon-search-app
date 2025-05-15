import SwiftUI

struct ContentView: View {
   
 @State private var inputName: String = "" // 検索入力文字列
 @State private var detail: PokemonDetail? // 詳細情報
 @State private var species: SpeciesInfo? // 種族情報
 @State private var errorMessage: String? // エラー表示用
 @State private var favorites: [String] = FavoriteManager.load() // お気に入り一覧
 @State private var showFavorites = false // お気に入りシート表示状態
    @EnvironmentObject var pokeData: PokeData // 日本語名マップのデータ提供

    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    Image("Pokehaikei5")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .ignoresSafeArea()
                        .opacity(0.2)
                    }

                VStack(spacing: 20) {
                    TextField("ポケモン名（日本語または英語）を入力", text: $inputName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button("検索") {
                        Task {
                            await searchPokemon()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    
                    if let detail, let species {
                        VStack(spacing: 12) {
                            AsyncImage(url: detail.sprites.frontDefault) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                            } placeholder: {
                                ProgressView()
                            }
                            
                            let japaneseName = species.names.first(where: { $0.language.name == "ja-Hrkt" })?.name ?? detail.name.capitalized
                            let typesJP = detail.types.map { typeMap[$0.type.name] ?? $0.type.name }
                            
                            Text("名前: \(japaneseName)")
                                .font(.headline)
                            
                            Text("タイプ: \(typesJP.joined(separator: ", "))")
                            Text("身長: \(detail.height)　体重: \(detail.weight)")
                            
                            if let flavor = species.flavorTextEntries.first(where: { $0.language.name == "ja" }) {
                                Text(flavor.flavorText.replacingOccurrences(of: "\n", with: " "))
                                    .font(.footnote)
                                    .padding(.top)
                            }
                            
                            Button(favorites.contains(japaneseName) ? "お気に入り解除" : "お気に入りに追加") {
                                favorites = FavoriteManager.toggle(japaneseName)
                            }
                            .padding(.top)
                        }
                        .padding()
                    }
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Divider()
                    Spacer()
                    
                    Button("お気に入りを見る") {
                        showFavorites = true
                    }
                    .sheet(isPresented: $showFavorites) {
                        FavoriteListView(favorites: favorites) { selectedName in
                            showFavorites = false
                            inputName = selectedName
                            Task {
                                await searchPokemon(with: selectedName)
                            }
                        }
                    }

                    
                    
                    Spacer()
                } // VStack
                .navigationTitle("ポケモン検索")
                .padding()
                .task {
                    await pokeData.generateNameMap()
                }
            }
        }
    }
    
    
    // ポケモン名から詳細と種族情報を取得して表示する
    func searchPokemon(with name: String? = nil) async {
        let rawInput = (name ?? inputName).trimmingCharacters(in: .whitespacesAndNewlines)
        let searchKey = pokeData.nameMap[rawInput] ?? rawInput.lowercased()

        do {
            let detailURL = URL(string: "https://pokeapi.co/api/v2/pokemon/\(searchKey)")!
            let (data, _) = try await URLSession.shared.data(from: detailURL)
            let decodedDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
            self.detail = decodedDetail

            let speciesURL = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(decodedDetail.id)")!
            let (speciesData, _) = try await URLSession.shared.data(from: speciesURL)
            self.species = try JSONDecoder().decode(SpeciesInfo.self, from: speciesData)

            self.errorMessage = nil
        } catch {
            self.errorMessage = "ポケモンが見つかりませんでした"
            self.detail = nil
            self.species = nil
        }
    }

}

#Preview {
    ContentView()
        .environmentObject(PokeData())
}

//
//  SearchViewModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class SearchViewModel {
    private var currentSearchText = ""
    private var currentPage = 0
    private var totalItens = 0
    
    var searchText = ""
    var results: [ITunesItem] = []
    
    var isLoading = false
    
    private var hasMore = true
    
    private let api: iTunesSearchAPI
    private let router: Router

    init(api: iTunesSearchAPI = iTunesSearchAPI(), router: Router) {
        self.api = api
        self.router = router
    }
    
    func buildMusicList() {
        
    }
    
    func didClickOnSong(_ item: ITunesItem, into context: ModelContext) {
        save(item, into: context)
        router.push(.playScreen(item))
    }

    private func save(_ item: ITunesItem, into context: ModelContext) {
        guard let model = TracksItensModel(from: item) else {
            return
        }
        context.insert(model)
    }
    
    func search() async {
        currentSearchText = searchText.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? searchText

        do {
            let response = try await api.searchMusics(term: currentSearchText, page: currentPage)
            totalItens = response.resultCount
            results = response.results.filter { $0.kind == .song }
        } catch {
            print("Search error: \(error)")
            results = []
        }
    }
    
    func nextPage() async {
        guard !isLoading, hasMore else { return }
           isLoading = true
           defer { isLoading = false }

           do {
               currentPage += 1
               let response = try await api.searchMusics(term: currentSearchText, page: currentPage)
               let filtredResults = response.results.filter { $0.kind == .song }
               results.append(contentsOf: filtredResults)
               hasMore = currentPage * 20 < totalItens
           } catch {
               currentPage -= 1
               // tratar/retry
           }
    }
}

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
    private let api: iTunesSearchAPI
    private let router: Router
    private let context: ModelContext
    
    private var currentSearchText = ""
    private var currentPage = 0
    private var totalItens = 0
    var searchText = ""
    var findedMusics: [TrackItemModel] = []
    private(set) var recentTracks: [TrackItemModel] = []

    var isLoading = false
    private var hasMore = true
    
    var displayedTracks: [TrackItemModel] {
        searchText.isEmpty ? recentTracks : findedMusics
    }

    init(api: iTunesSearchAPI = iTunesSearchAPI(), context: ModelContext, router: Router) {
        self.api = api
        self.router = router
        self.context = context
    }
    
    func didClickOnSong(_ item: TrackItemModel) {
        save(item)
        router.push(.playScreen(item))
    }

    func loadRecents() {
        let descriptor = FetchDescriptor<TrackItemModel>(
            sortBy: [SortDescriptor(\.insertedAt, order: .reverse)]
        )
        
        do {
            recentTracks = try context.fetch(descriptor)
        } catch {
            recentTracks = []
            // error
        }
    }

    func save(_ item: TrackItemModel) {
        let id = String(item.id)
        let descriptor = FetchDescriptor<TrackItemModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.insertedAt = .now
        } else {
            context.insert(item)
        }

        try? context.save()
    }
    
    func search() async {
        currentSearchText = searchText.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? searchText

        do {
            let response = try await api.searchMusics(term: currentSearchText, page: currentPage)
            totalItens = response.resultCount
            let musics = response.results
                 .filter { $0.kind == .song }
                 .compactMap { TrackItemModel(from: $0) }
             findedMusics.append(contentsOf: musics)
        } catch {
            print("Search error: \(error)")
            findedMusics = []
        }
    }
    
    func nextPage() async {
        guard !isLoading, hasMore else { return }
           isLoading = true
           defer { isLoading = false }

           do {
               currentPage += 1
               let response = try await api.searchMusics(term: currentSearchText, page: currentPage)
               let musics = response.results
                    .filter { $0.kind == .song }
                    .compactMap { TrackItemModel(from: $0) }
               findedMusics.append(contentsOf: musics)
               hasMore = currentPage * 20 < totalItens
           } catch {
               currentPage -= 1
               // tratar/retry
           }
    }
}

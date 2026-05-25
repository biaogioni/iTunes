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
    
    var findedMusics: [TrackItemModel] = []
    private(set) var recentTracks: [TrackItemModel] = []
    private var searchTask: Task<Void, Never>?
    
    private var isLoading = false
    private var hasMore = true
    
    var displayedTracks: [TrackItemModel] {
        searchText.isEmpty ? recentTracks : findedMusics
    }
    
    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            debounceSearch()
        }
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
    
    func didClickInMoreInfo(musicInfo: TrackItemModel) {
        router.presentSheet(musicInfo)
    }
    
    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await search()
        }
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
        guard !searchText.isEmpty else {
            findedMusics = []
            return
        }
        
        currentPage = 0
        findedMusics = []
        await loadPage()
    }
    
    func nextPage() async {
        guard !isLoading,
              findedMusics.count < totalItens else { return }
        currentPage += 1
        await loadPage()
    }
    
    private func loadPage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        let term = searchText.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? searchText
        
        do {
            let response = try await api.searchMusics(term: term, page: currentPage)
            totalItens = response.resultCount
            
            let musics = response.results
                .filter { $0.kind == .song }
                .compactMap { TrackItemModel(from: $0) }
            
            findedMusics.append(contentsOf: musics)
        } catch {
            print("Search error: \(error)")
        }
    }
}

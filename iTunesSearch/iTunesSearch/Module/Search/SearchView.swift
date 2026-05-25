//
//  SearchView.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TracksItensModel.id) private var savedTracks: [TracksItensModel]
    
    @State private var viewModel: SearchViewModel
    @State private var isSearching = true
    @FocusState private var searchFieldFocused: Bool
    
    init(router: Router) {
        _viewModel = State(wrappedValue: SearchViewModel(router: router))
    }

    var body: some View {
        if isSearching {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .focused($searchFieldFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await viewModel.search()
                            withAnimation {
                                isSearching = false
                            }
                        }
                    }
                if !viewModel.searchText.isEmpty {
                    Button { viewModel.searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.regularMaterial, in: .capsule)
            .padding(.horizontal, 10)
        }
        List() {
            if !viewModel.searchText.isEmpty {
                ForEach(viewModel.results, id: \.trackId) { item in
                    resultRow(item)
                }
            } else {
                let _ = print("savedTracks count: \(savedTracks.count)")
                ForEach(savedTracks) { track in
                   SongRow(trackName: track.trackName,
                           singer: track.singer,
                           coverURL: track.musicCover)
                       .listRowSeparator(.hidden)
                       .listRowBackground(Color.clear)
               }
            }
        }
        .navigationTitle("Songs")
        .navigationBarTitleDisplayMode(isSearching ? .large : .inline)
        .toolbar {
            if !isSearching {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Search", systemImage: "magnifyingglass") {
                        isSearching = true
                        searchFieldFocused = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func resultRow(_ item: ITunesItem) -> some View {
        SongRow(trackName: item.trackName ?? "",
                singer: item.artistName ?? "",
                coverURL: item.artworkUrl100)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.didClickOnSong(item, into: modelContext)
            }
            .onAppear {
                if item.trackId == viewModel.results.last?.trackId {
                    Task { await viewModel.nextPage() }
                }
            }
    }
}

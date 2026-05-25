//
//  SearchView.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @State private var isSearching = true
    @FocusState private var searchFieldFocused: Bool
    
    init(context: ModelContext, router: Router) {
        _viewModel = State(wrappedValue: SearchViewModel(context: context, router: router))
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
        List(viewModel.displayedTracks) { item in
            SongRow(trackName: item.trackName,
                    singer: item.singer,
                    coverURL: item.musicCover,
                    hasMoreOptions: true) {
                print("pegou o click")
            }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.didClickOnSong(item)
                }
                .onAppear {
                    if item.id == viewModel.findedMusics.last?.id {
                        Task { await viewModel.nextPage() }
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
        }.onAppear {
            viewModel.loadRecents()
        }
    }
}

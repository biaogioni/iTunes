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
            SearchBar(text: $viewModel.searchText, focused: $searchFieldFocused) {
                Task {
                    await viewModel.search()
                    withAnimation { isSearching = false }
                }
            }
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
        .listStyle(.plain)
        
        .navigationTitle("Songs")
        .navigationBarTitleDisplayMode(isSearching ? .large : .inline)
        .toolbar {
            if !isSearching {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isSearching = true
                        searchFieldFocused = true
                    } label: {
                        Image(symbol: .magnifyingglass)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadRecents()
        }
    }
}

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
        List(Array(viewModel.displayedTracks.enumerated()), id: \.element.id) { index, item in
            SongRow(trackName: item.trackName,
                    singer: item.singer,
                    coverURL: item.musicCover,
                    coverData: item.coverData,
                    hasMoreOptions: true) {
                viewModel.didClickInMoreInfo(musicInfo: item)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .contentShape(Rectangle())
            .onTapGesture {
                Task {
                    await viewModel.didClickOnSong(index)
                }
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
                        Image(.magnifyingglass)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadRecents()
        }
    }
}

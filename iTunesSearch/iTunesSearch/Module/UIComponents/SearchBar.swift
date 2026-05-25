//
//  SearchBar.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//


import SwiftUI
 
struct SearchBar: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    var placeholder: String = "Search"
    var onSubmit: () -> Void
 
    var body: some View {
        HStack {
            Image(symbol: .magnifyingglass)
                .foregroundStyle(.element25)
                .padding(.leading, 18)
 
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .focused(focused)
                .font(.system(size: 16, weight: .medium))
                .submitLabel(.search)
                .foregroundStyle(.text01)
                .onSubmit(onSubmit)
 
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(symbol: .xmarkCircleFill)
                        .foregroundStyle(.element25)
                }
                .padding(.trailing, 18)
            }
        }
        .padding(.vertical, 12)
        .background(.element10)
        .cornerRadius(12)
        .padding(.horizontal, 10)
    }
}
 
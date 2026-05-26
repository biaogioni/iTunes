//
//  ErrorAlert.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import SwiftUI

struct ErrorAlert: ViewModifier {
    @Binding var isPresented: Bool
    var title: String = "Oh no! Something went wrong :("
    var message: String = "Couldn't load the songs. Please try again."

    func body(content: Content) -> some View {
        content.alert(title, isPresented: $isPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(message)
        }
    }
}

extension View {
    func errorAlert(
        isPresented: Binding<Bool>,
        title: String = "Oh no! Something went wrong :(",
        message: String = "Couldn't load the songs. Please try again."
    ) -> some View {
        modifier(ErrorAlert(isPresented: isPresented, title: title, message: message))
    }
}

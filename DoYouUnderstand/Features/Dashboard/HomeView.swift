//
//  HomeView.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

struct HomeView: View {
    
    @State var viewModel: HomeViewModel
    
    init(output: @escaping (HomeViewModel.Output) -> Void) {
        self.viewModel = .init(output: output)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button {
            viewModel.actions.onNavigate?(.input)
        } label: {
            Text("Input")
        }
    }
}

//#Preview {
//    HomeView()
//}

//
//  CandidatesListView.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import SwiftUI

struct CandidatesListView: View {
    
    @StateObject private var viewModel = CandidateViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
            }
            .searchable(text: $viewModel.searchText)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CandidatesToolbar(viewModel: viewModel)
                }
            }
            
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    CandidatesListView()
}

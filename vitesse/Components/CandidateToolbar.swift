//
//  CandidatesToolbar.swift
//  vitesse
//
//  Created by pascal jesenberger on 07/03/2025.
//

import SwiftUI

struct CandidateToolbar: ToolbarContent {
    @ObservedObject var viewModel: CandidateViewModel
    var onSave: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if viewModel.isEditingCandidate {
                Button(action: {
                    viewModel.isEditingCandidate = false
                }) {
                    Text("Cancel")
                }
                .foregroundColor(.black)
            }
        }

        ToolbarItem(placement: .navigationBarLeading) {
            if !viewModel.isEditingCandidate {
                BackButton {
                    dismiss()
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            if !viewModel.isEditingCandidate {
                Button("Edit") {
                    viewModel.isEditingCandidate = true
                }
                .foregroundColor(.black)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.isEditingCandidate {
                Button("Done") {
                    if let onSave = onSave {
                        onSave()
                    } else {
                        viewModel.isEditingCandidate = false
                    }
                }
                .foregroundColor(.black)
            }
        }
    }
}

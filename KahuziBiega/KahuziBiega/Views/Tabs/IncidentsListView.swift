//
//  IncidentsListView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct IncidentsListView: View {
    @Environment(\.dismiss) private var dismiss
    private let incidents = Incident.incidents + Incident.recents
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(incidents) { incident in
                    Group {
                        RecentReportRowView(incident: incident)
                        
                        if (incidents.last?.id != incident.id) {
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .bold()
                }
                
                Spacer()
                Text("List of Incidents")
                    .bold()
                Spacer()
                Button(action: {}) {
                    Image(.more)
                }
            }
            .padding()
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    IncidentsListView()
}

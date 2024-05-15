//
//  IncidentsListView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct IncidentsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var incidentsStore: IncidentsStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(incidentsStore.allIncidents) { incident in
                    Group {
                        RecentReportRowView(incident: incident)
                        
                        if (incidentsStore.allIncidents.last?.id != incident.id) {
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
                }.hidden()
            }
            .padding()
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .loadingIndicator(isVisible: incidentsStore.isLoading)
    }
}

#Preview {
    let mock = IncidentsStore(client: IncidentsClientMock())
    return IncidentsListView()
        .task {
            await mock.getIncidents()
        }
        .environmentObject(mock)
}

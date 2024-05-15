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
    @State private var showSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(incidentsStore.allIncidents) { incident in
                    Group {
                        NavigationLink {
                            IncidentDetailView(incident: incident)
                        } label: {
                            RecentReportRowView(incident: incident)
                        }
                        .buttonStyle(.plain)
                        
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
                Button(action: {
                    showSheet.toggle()
                }) {
                    Label("Add new", systemImage: "plus.circle")
                        .labelStyle(.iconOnly)
                }
//                .hidden()
            }
            .padding()
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .loadingIndicator(isVisible: incidentsStore.isLoading)
        .fullScreenCover(isPresented: $showSheet) {
            IncidentCreationView()
        }
    }
}

#Preview {
    let mock = IncidentsStore(client: IncidentsClientMock())
    return IncidentsListView()
        .task {
            await mock.getIncidents()
        }
        .embedInNavigation()
        .environmentObject(mock)
}

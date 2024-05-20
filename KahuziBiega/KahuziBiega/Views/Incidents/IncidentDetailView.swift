//
//  IncidentDetailView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 15/05/2024.
//

import SwiftUI

struct IncidentDetailView: View {
    let incident: KBIncident
    
    private var incidentImg: String? {
        incident.report.attachments?.first(where: { $0.type == .Photo })?.url
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                         
                if let incidentImg {
                    KBImage(incidentImg) {
                        EmptyView()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .background(.gray)
                    .clipped()
                }
                
                Text(incident.report.title)
                    .font(.title)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.title3.weight(.bold))
                    
                    Text(incident.report.description)
                        .opacity(0.8)
                }
                
                .padding(.top, 5)
                
                Divider()
                
                
                if let comments = incident.report.comments {
                    vStackContent("Comments", value: comments)
                }
                
                
                HStack {
                    hStackContent("Category:") {
                        Text(incident.category.formatted)
                            .fontWeight(.bold)
                            .foregroundStyle(.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let user = LocalStorage.getSessionUser(), user.role > .User {
                        Menu {
                            ForEach(KBIncident.Category.allCases, id: \.self) { category in
                                Button(action: { updateCategory(category) }, label: {
                                    Label(
                                        title: { Text(category.rawValue).foregroundStyle(.red) },
                                        icon: {
                                            if incident.category == category {
                                                Image(systemName: "checkmark")
                                                
                                            }
                                        }
                                    )
                                })
                            }
                        } label: {
                            Text("Update")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .foregroundStyle(.accent)
                                .background(.gray.quaternary)
                                .clipShape(.capsule)
                                .font(.callout)
                        }
                    }
                }
                Divider()
                
                
                HStack {
                    hStackContent("Status:") {
                        Text(incident.status.formatted)
                            .foregroundStyle(.accent)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Menu {
                        ForEach(KBIncident.Status.allCases, id: \.self) { status in
                            Button(status.rawValue, action: { updateStatus(status) })
                        }
                    } label: {
                        Text("Update")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .foregroundStyle(.accent)
                            .background(.gray.quaternary)
                            .clipShape(.capsule)
                            .font(.callout)
                    }
                    
                }
                
                Divider()
                
                hStackContent("Priority: ") {
                    PriorityCapsuleView(priority: incident.priority, isActive: true)
                        .frame(maxWidth: 80)
                }
                
                Divider()
                
                hStackContent("Reported at:") {
                    Text(incident.createAt.formatted(date: .long, time: .shortened))
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                
                Spacer()
                
                hStackContent("Reported by:") {
                    Text(incident.report.reporter.fullName)
                        .fontWeight(.semibold)
                        .foregroundStyle(.accent)
                }
                
            }
            .padding()
        }
        .navigationTitle("By " + incident.report.reporter.usernameFormatted)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func updateCategory(_ category: KBIncident.Category) {
        Task {
            // Update category
        }
    }
    
    private func updateStatus(_ status: KBIncident.Status) {
        Task {
            // Update status
        }
    }
}

#Preview {
    IncidentDetailView(incident: .recents[0])
        .embedInNavigation(large: false)
}

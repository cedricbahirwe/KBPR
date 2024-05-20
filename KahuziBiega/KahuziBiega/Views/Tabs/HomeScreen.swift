//
//  HomeScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var incidentsStore: IncidentsStore
    @State private var showSheet = false

    private var recentIncidentReports: [KBIncident] {
        incidentsStore.getRecents(max: 6)
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 25) {
                    Button(action: {
                        showSheet.toggle()
                    }) {
                        Image(.reportIncident)
                            .resizable()
                    }
                    
                    NavigationLink {
                        IncidentsListView()
                    } label: {
                        Image(.viewReport)
                            .resizable()
                    }
                }
                .scaledToFit()
                .padding(20)
                .background(.background, in: .rect(cornerRadius: 20.0))
                
                
                if !recentIncidentReports.isEmpty {
                    LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                        Section {
                            VStack(alignment: .leading) {
                                ForEach(recentIncidentReports) { incident in
                                    NavigationLink {
                                        IncidentDetailView(incident: incident)
                                    } label: {
                                        //                                    ReportRowView(incident: incident)
                                        RecentReportRowView(incident: incident)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if (recentIncidentReports.last?.id != incident.id) {
                                        Divider()
                                    }
                                }
                            }
                            .padding()
                            .background(
                                .background
                                    .shadow(.inner(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4))
                                , in: .rect(cornerRadius: 15)
                            )
                        } header: {
                            Text("Recent Reports")
                                .font(.title.bold())
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.background.opacity(0.9))
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Kauzi Biega Park")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 16) {
                    NavigationLink {
                        MapScreen()
                    } label: {
                        Image(.mapMarker)
                    }
                    
                    Button(action: {}) {
                        Image(.siren)
                    }
                }
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(.radioTower)
                }
                
                Button(action: {
                    NotificationCenter.default.post(name: .unauthorizedRequest, object: nil)
                }) {
                    
                    KBImage(LocalStorage.getSessionUser()?.profilePic) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .frame(width: 35, height: 35)
                    .background(.regularMaterial)
                    .clipShape(.circle)
                }
            }
        }
        .loadingIndicator(isVisible: incidentsStore.isLoading)
        .task {
            await incidentsStore.getIncidents()
        }
        .fullScreenCover(isPresented: $showSheet) {
            IncidentCreationView()
        }
    }
}

#Preview {
    HomeScreen()
        .embedInNavigation()
        .environmentObject(IncidentsStore(client: IncidentsClientMock()))
}

struct ReportRowView: View {
    let incident: KBIncident
    var report: KBIncident.Report { incident.report }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, h:mm a"
        return formatter
    }()
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(report.title)
                .fontWeight(.semibold)
            
            Text(report.description)
                .fontWeight(.light)
            
            if let area = report.area {
                HStack {
                    Text("Location: \(Text(area.name).bold())")
                        .foregroundStyle(.accent)
                }
            }
            HStack {
                
                Group {
                    Label(dateFormatter.string(from: incident.createAt), systemImage: "calendar")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(8)
                        .background(.tint.quinary.opacity(0.3), in: .rect(cornerRadius: 10))
                        .foregroundStyle(.accent)
                    
                    Spacer()
                    
                    Text("In Review")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(8)
                        .background(.tint.quinary.opacity(0.3), in: .capsule)
                        .foregroundStyle(.accent)
                }
            }
        }
    }
}


//VStack(alignment: .leading, spacing: 0) {
//    Text("Park Statistics").bold()
//        .padding()
//    
//    VStack(alignment: .leading, spacing: 5) {
//        Divider()
//        Text("138 \(Text("Visitors today").font(.title3).foregroundStyle(.secondary).baselineOffset(5))")
//            .font(.largeTitle.bold())
//    }
//    .padding(.horizontal)
//    
//    VStack(alignment: .leading, spacing: 5) {
//        Divider()
//        
//        Text(
//            "015 \(Text("Incidents reported today").font(.title3).foregroundStyle(.secondary).baselineOffset(5))"
//        )
//        .font(.largeTitle.bold())
//    }
//    .padding(.horizontal)
//    
////                    Map()
//    Image(.heatMap)
//        .frame(height: 200)
//    
//}
//.clipShape(.rect(cornerRadius: 15.0))
//.background(
//    .background
//        .shadow(.inner(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4))
//    , in: .rect(cornerRadius: 15)
//)
//.padding()

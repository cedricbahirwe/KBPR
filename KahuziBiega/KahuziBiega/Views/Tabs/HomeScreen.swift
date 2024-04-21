//
//  HomeScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI
import MapKit

struct HomeScreen: View {
    @Binding var navPath: [AppRoute]
    private let incidents = Incident.incidents
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(incidents) { incident in
                        Group {
                            ReportRowView(incident: incident)
                            
                            if (incidents.last?.id != incident.id) {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(
                    .background
                        .shadow(.inner(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4))
                    , in: .rect(cornerRadius: 15)
                )
                .padding()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Park Statistics").bold()
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Divider()
                        Text("138 \(Text("Visitors today").font(.title3).foregroundStyle(.secondary).baselineOffset(5))")
                            .font(.largeTitle.bold())
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Divider()
                        
                        Text(
                            "015 \(Text("Incidents reported today").font(.title3).foregroundStyle(.secondary).baselineOffset(5))"
                        )
                        .font(.largeTitle.bold())
                    }
                    .padding(.horizontal)
                    
//                    Map()
                    Image(.heatMap)
                        .frame(height: 200)
                    
                }
                .clipShape(.rect(cornerRadius: 15.0))
                .background(
                    .background
                        .shadow(.inner(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4))
                    , in: .rect(cornerRadius: 15)
                )
                .padding()
                
            }
        }
        .safeAreaInset(edge: .top) {
            topBarView
                .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
    }
}

#Preview {
    HomeScreen(navPath: .constant([]))
}

private extension HomeScreen {
    var topBarView: some View {
        HStack {
            HStack(spacing: 16) {
                Button(action: {
                    
                }) {
                    Image(.mapMarker)
                }
                Button(action: {}) {
                    Image(.siren)
                }
            }
            
            Text("Kauzi Biega Park")
                .bold()
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(.radioTower)
                }
                
                Button(action: {}) {
                    Image(.avatarImg)
                }
            }
        }
        .padding()
    }
}


struct Incident:Identifiable {
    let id: UUID = UUID()
    var report: Incident.Report
    var status: Incident.Status
    
    struct Report: Identifiable {
        let id: UUID = UUID()
        var title: String
        var description: String
        var date: Date = .now
        var area: ParkArea
        
        static let report1 = Report(
            title: "Illegal hunting activity near the Visitor Center Area",
            description: "On the morning patrol, encountered a group of visitors near the Eastern Trail Area who had an unexpected ..",
            area: .example
        )
        
        static let report2 = Report(
            title: "Another Incident XYZ",
            description: "Something happened in the night and should check this and that before or access....",
            area: .example1
        )
        
        static let report3 = Report(
            title: "Encounter with juvenile mountain gorilla",
            description: "On the morning patrol, encountered a group of visitors near the Eastern Trail Area who had an unexpected close encounter with a juvenile mountain gorilla.",
            area: .example1
        )
        
        static let report4 = Report(
            title: "Illegal hunting activity near the Visitor Center Area.",
            description: "Upon investigation, discovered evidence of poaching, including animal traps and remains of a hunted antelope. The perpetrators had already fled the scene before ...",
            area: .example1
        )
    }
    
    enum Status: String {
        case inReview, resolved, pending
        var rawValue: String {
            switch self {
            case .inReview:
                "In Review"
            case .resolved:
                "Resolved"
            case .pending:
                "Pending"
            }
        }
    }
    
    static let incidents = [
        Incident(report: .report1, status: .inReview),
        Incident(report: .report2, status: .inReview)
    ]
    
    static let recents = [
        Incident(report: .report3, status: .inReview),
        Incident(report: .report4, status: .resolved),
    ]
}

struct ParkArea {
    var name: String
    var latitude: Double
    var longitude: Double
    
    static let example = ParkArea(name: "Visitor Center Area", latitude: 0.0032123, longitude: -1.2141241)
    static let example1 = ParkArea(name: "Mountain Gorilla North Wing", latitude: 0.012123, longitude: -1.141241)
}


struct ReportRowView: View {
    let incident: Incident
    var report: Incident.Report { incident.report }
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
            
            HStack {
                Text("Location: \(Text(report.area.name).bold())")
                    .foregroundStyle(.accent)
            }
            
            HStack {
                
                Group {
                    Label(dateFormatter.string(from: report.date), systemImage: "calendar")
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

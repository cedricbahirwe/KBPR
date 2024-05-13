//
//  ReportScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct ReportScreen: View {
    @State private var reports: [KBIncident] = []
    
    var body: some View {
        ScrollView {
            
            VStack {
                HStack(spacing: 25) {
                    Button(action: {}) {
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
                
                VStack(alignment: .leading) {
                    Text("Recent Reports")
                        .font(.title.bold())
                    
                    ForEach(reports) { report in
                        Group {
                            RecentReportRowView(incident: report)
                            
                            if (reports.last?.id != report.id) {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            
        }
        .background(Color(red: 242/255, green: 246/255, blue: 249/255))
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: {}) {
                    Image(.menuLines)
                }
                
                Spacer()
                Text("Reporting").bold()
                
                Spacer()
                Button(action: {}) {
                    Image(.more)
                }
            }
            .padding()
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
        .task {
//            do {
//                let userData = try await NetworkClient.shared.getUserData()
//                
//            } catch {
//                // Handle errors
//                print("Error found: ", error)
//            }
            
            getRecentReports()
        }
    }
    
    private func getRecentReports() {
//        do {
//            let result: [KBIncident] = try LocalDecoder.decodeAs()
//            self.reports = result + KBIncident.recents
//        } catch {
//            print("Error incidents: ", error)
//        }
    }
}

#Preview {
    ReportScreen()
}

struct RecentReportRowView: View {
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
                .fontWeight(.medium)
            
            Text(report.description)
                .fontWeight(.light)
            
            HStack {
                
                Group {
                    Label(dateFormatter.string(from: incident.createAt), systemImage: "calendar")
                        .font(.callout.weight(.light))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(incident.status.formatted)
                        .font(.callout.weight(.semibold))
                        .padding(8)
                        .background(statusColors.quinary.opacity(0.3), in: .capsule)
                        .foregroundStyle(statusColors)
                }
            }
        }
    }
    
    var statusColors: Color {
        switch incident.status {
        case .pending:
                .blue
        case .inReview:
                .yellow
        case .resolved:
                .green
        }
    }
}

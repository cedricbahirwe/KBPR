//
//  ReportScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct ReportScreen: View {
    private let reports = Incident.recents
    
    var body: some View {
        ScrollView {
            
            VStack {
                HStack(spacing: 25) {
                    Button(action: {}) {
                        Image(.reportIncident)
                            .resizable()
                    }
                    
                    Button(action: {}) {
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
                Text("Reporting")
                Spacer()
                Button(action: {}) {
                    Image(.more)
                }
            }
            .padding()
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
    }
}

#Preview {
    ReportScreen()
}

private struct RecentReportRowView: View {
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
                .fontWeight(.medium)
            
            Text(report.description)
                .fontWeight(.light)
            
            HStack {
                
                Group {
                    Label(dateFormatter.string(from: report.date), systemImage: "calendar")
                        .font(.callout.weight(.light))
                        .foregroundStyle(.accent)
                    
                    Spacer()
                    
                    Text("In Review")
                        .font(.callout.weight(.semibold))
                        .padding(8)
                        .background(.tint.quinary.opacity(0.3), in: .capsule)
                        .foregroundStyle(.accent)
                }
            }
        }
    }
}

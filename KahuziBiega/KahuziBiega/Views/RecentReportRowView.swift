//
//  RecentReportRowView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/05/2024.
//

import SwiftUI

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
            Group {
                Text(report.title)
                    .fontWeight(.medium)
                
                Text(report.description)
                    .fontWeight(.light)
            }
            .multilineTextAlignment(.leading)
            
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
        incident.status.color
    }
}

#Preview {
    RecentReportRowView(incident: .recents[0])
}

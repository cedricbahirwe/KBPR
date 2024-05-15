//
//  IncidentDetailView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 15/05/2024.
//

import SwiftUI

struct IncidentDetailView: View {
    let incident: KBIncident
    var body: some View {
        VStack {
            Text(incident.report.title)
        }
    }
}

#Preview {
    IncidentDetailView(incident: .recents[0])
}

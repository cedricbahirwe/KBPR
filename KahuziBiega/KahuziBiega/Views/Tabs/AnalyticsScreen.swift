//
//  AnalyticsScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI
import Charts


struct IncidentByCategory: Identifiable {
    var id: KBIncident.Category { key }
    let key: KBIncident.Category
    var value: Double
}

struct IncidentsOverTime: Identifiable {
    var id: Date { key }
    let key: Date
    var value: Double
}

struct AnalyticsScreen: View {
    @State private  var incidents: [KBIncident] = try! LocalDecoder.decodeAs(from: .incidents)
    
    var incidentsByCategory: [IncidentByCategory] {
        var counts: [KBIncident.Category: Double] = [:]
        for incident in incidents {
            counts[incident.category, default: 0] += 1
        }
        let result =  counts.map { IncidentByCategory(key: $0.key, value: $0.value / Double(incidents.count)) }
        return result.sorted(by: { $0.value > $1.value })
    }
    
    @State private var selectedCategory = KBIncident.Category.safety
    var incidentsBySelectedCategory: [KBIncident] {
        incidents.filter({ $0.category == selectedCategory })
    }
    
    var incidentsOverTime: [IncidentsOverTime] {
        var results = [Date: Double]()
        for incident in incidents {
            results[incident.createAt, default: 0] += 1
        }
        
        let result =  results.map { IncidentsOverTime(key: $0.key, value: $0.value) }
        return result//.sorted(by: { $0.value > $1.value })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Reported incidents by category")
                .font(.title.bold())
                .fontDesign(.serif)

            Chart(incidentsByCategory) { incidentByCategory in
                SectorMark(
                    angle: .value(
                        Text(verbatim: incidentByCategory.key.formatted),
                        incidentByCategory.value
                    ),
                    innerRadius: .automatic,
                    angularInset: 0.5
                )
                .foregroundStyle(
                    by: .value(
                        Text(verbatim: incidentByCategory.key.formatted),
                        incidentByCategory.key.formatted
                    )
                )
            }
            
            .frame(maxHeight: 300)

            Text("Reported incidents in the last 4 months")
                .font(.title.bold())
                .fontDesign(.serif)
            
            Chart {
                ForEach(incidentsOverTime, id: \.key) { incident in
                    BarMark(
                        x: .value("Month", incident.key, unit: .month),
                        y: .value("Incidents", incident.value * Double.random(in: 10...100))
                    )
                    .foregroundStyle(
                        by: .value(
                            Text(verbatim: incident.key.formatted()),
                            incident.key, unit: .month
                        )
                    )
                }
                
//                ForEach(incidents, id: \.createAt) { incident in
//                    BarMark(
//                        x: .value("City", incident.category.rawValue),// incident.createAt),
//                        y: .value("Population", incident.createAt.timeIntervalSince1970)// incident.category.rawValue)
//                    )
//                }
            }
            .frame(maxHeight: 300)
            Spacer()
            
            
//            FlippableView()
        }
        .padding()
        .onAppear() {
            print("Receive", incidents)
        }
    }
}

#Preview {
    AnalyticsScreen()
}

import SwiftUI

struct FlippableView: View {
    @State private var isFlipped = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if !isFlipped {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: 200, height: 200)
                        .overlay(content: {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Color.red
                                    Color.green
                                }
                                HStack(spacing: 0) {
                                    Color.blue
                                    Color.black
                                }
                            }
                        })
                        .cornerRadius(20)
                        .rotation3DEffect(
                            .degrees(0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                } else {
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 200, height: 200)
                        .overlay(content: {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Color.orange
                                    Color.yellow
                                }
                                HStack(spacing: 0) {
                                    Color.purple
                                    Color.teal
                                }
                            }
                        })
                        .cornerRadius(20)

                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                }
            }
            .scaleEffect(x: isFlipped ? -1 : 1, y: 1, anchor: .center) // Flip horizontally from center
            
            Spacer()
            
            Button("Flip") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isFlipped.toggle()
                }
            }
            
            Spacer()
        }
    }
}


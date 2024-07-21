//
//  AnalyticsScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI
import Charts
import MapKit

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
        let valuesTotal = counts.values.reduce(0, +)
        let result =  counts.map { IncidentByCategory(key: $0.key, value: $0.value / Double(valuesTotal)) }
        return result.sorted(by: { $0.value > $1.value })
    }
    
    @State private var selectedCategory = KBIncident.Category.safety
    var incidentsBySelectedCategory: [KBIncident] {
        incidents.filter({ $0.category == selectedCategory })
    }
    
    var incidentsOverTime: [IncidentsOverTime] {
        var results = [Date: Double]()
        let calendar = Calendar.current
        
        for incident in incidents {
            let components = calendar.dateComponents([.year, .month], from: incident.createAt)
            if let monthDate = calendar.date(from: components) {
                results[monthDate, default: 0] += 1
            }
        }
        
        // We multiply by 30 for simulation purpose
        var result = results.map { IncidentsOverTime(key: $0.key, value: $0.value * 30.0) }
            .sorted { $0.key < $1.key }
        
        result[2].value = 150
        
        return result
    }
    
    var months: [Date] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let months = (5...12).compactMap { calendar.date(from: DateComponents(year: currentYear, month: $0)) }
        return months
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                incidentsByCategoryView
                    .padding()
                Divider()
                incidentsOverYear
                    .padding()
                
                Divider()
               incidentsOnMap
                                
            }
        }
        .navigationTitle(Text("Analytics"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func rangeCategory(for value: Double) -> String {
        switch value {
        case 0..<50:
            return "Low"
        case 50..<100:
            return "Medium"
        case 100..<150:
            return "High"
        default:
            return "Highest"
        }
    }
    
    private var incidentsByCategoryView: some View {
        VStack(alignment: .leading) {
            titleLabel("Reported incidents by category")
            
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
                .annotation(position: .overlay) {
                    Text(incidentByCategory.value, format: .percent.precision(.fractionLength(1)))
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.regularMaterial)
                }
            }
            .frame(height: 280)
        }
    }
    
    private var incidentsOverYear: some View {
        VStack(alignment: .leading) {
            titleLabel("Reported incidents in the last \(incidentsOverTime.count) months")
            Chart {
                ForEach(incidentsOverTime) { incident in
                    BarMark(
                        x: .value("Month",  incident.key, unit: .month),
                        y: .value("Number of incidents", incident.value)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Number of incidents", rangeCategory(for: incident.value)))
                }
            }
            .frame(height: 350)
            .chartXAxisLabel("Number of incidents:")
            .chartForegroundStyleScale([
                "Low": .green,
                "Medium": .blue,
                "High": .orange,
                "Highest": .red
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) {
                    AxisValueLabel(centered: true)
                    AxisGridLine()
                    AxisTick()
                }
            }
        }
    }
    
    @StateObject private var mapVM = MapViewModel()

    private var incidentsOnMap: some View {
        VStack(alignment: .leading) {
            titleLabel("Incident Distribution Map")
                .padding(.horizontal)
//            Image("incidents-distribution")
//                .resizable()
            MapView(viewModel: mapVM)
                .frame(height: 400)
                .overlay {
                    if let overlayImage = mapVM.heatmapImage {
                        Image(uiImage: overlayImage)
                            .resizable()
                            .allowsHitTesting(true)
                    }
                }
            
            Text("Geographic Distribution of Incident Frequency by Region")
                .foregroundStyle(.gray)
                .font(.callout).italic()
                .padding(.horizontal)
            
        }
    }
    
    private func titleLabel(_ title: String) -> some View {
        Text(title)
            .font(.title.bold())
            .fontDesign(.serif)
    }
}

#Preview {
//    PieChartView(data: data)
    ScrollView {
        AnalyticsScreen()
    }
    //        .embedInNavigation()
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

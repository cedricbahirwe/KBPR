//
//  IncidentCreationView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 15/05/2024.
//

import SwiftUI

private enum SubmissionValidation: Error {
    case missingPriority
    case missingCategory
    case missingReporter
    
    var message: String {
        switch self {
        case .missingPriority:
            return "Priority is missing."
        case .missingCategory:
            return "Category is missing."
        case .missingReporter:
            return "Reporter information is missing."
        }
    }
}
struct IncidentModel: Encodable {
   
    var priority: KBIncident.Priority?
    var category: KBIncident.Category?
    
    var report = ReportModel()
    
    
    func isValid() throws {
        guard priority != nil else { throw SubmissionValidation.missingPriority }
        guard category != nil else { throw SubmissionValidation.missingCategory }
        guard report.reporterId != nil else { throw SubmissionValidation.missingReporter }
    }
}

struct ReportModel: Encodable {
    var title = ""
    var description = ""
    var comments = ""
    var actionTaken = ""
    
//    var area:
    
    var attachments: [Attachment] = []
    
    var reporterId: KBUser.ID!
    
    
    
    struct Attachment: Encodable {
        let type: KBIncident.AttachmentType
        let url: String
    }
    
}

struct IncidentCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model = IncidentModel()
    
    var report: Binding<ReportModel>  { $model.report }
    @EnvironmentObject private var incidentsStore: IncidentsStore
    
    @State private var showAlert = false
       @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                vStackField("Incident Title", text: report.title)
                
                vStackContent("Incident Description") {
                    TextField("", text: report.description, axis: .vertical)
                        .padding(10.0)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.secondLabel)
                        }
                        .lineLimit(2...4)
                }
                
                vStackField("Additional Notes", text: report.comments)
                
                
//                vStackContent("Add Attachments") {
//                    HStack(spacing: 15) {
//                        Group {
//                            Image(systemName: "photo.fill")
//                                .resizable()
//                            Image(systemName: "camera.fill")
//                                .resizable()
//                            Image(systemName: "film.stack")
//                                .resizable()
//                        }
//                        .scaledToFit()
//                        .padding()
//                        .foregroundStyle(.tint)
//                    }
//                    .padding(10.0)
//                    
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 8)
//                            .strokeBorder(.secondLabel)
//                    }
//                }
                
                vStackContent("Incident Category") {
                    IncidentCategorySelector(selection: $model.category)
                }
                
                
                vStackContent("Priority Level") {
                    IncidentPrioritySelector(selection: $model.priority)
                }
                
                vStackContent("Action Taken") {
                    TextField("", text: report.actionTaken, axis: .vertical)
                        .padding(10.0)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.secondLabel)
                        }
                        .lineLimit(3, reservesSpace: true)

                }
            }
            .padding([.top, .horizontal])
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                hideKeyboard()
                submitReport()
            } label: {
                Text("Submit New Report")
                    .padding(5.0)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 12.0))
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial)
        }
        .loadingIndicator(isVisible: incidentsStore.isLoading)
        .safeAreaInset(edge: .top) {
            Text("Report Incident")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                .padding()
                
                .background(.ultraThinMaterial)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Validation Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        
    }
    
    private func submitReport() {
        Task {
            do {
                model.report.reporterId = LocalStorage.getSessionUser()?.id
                try model.isValid()
                print("✅ Ready to go")
                await incidentsStore.submitIncidentReport(model)
                dismiss()
            } catch {
                alertMessage = (error as? SubmissionValidation)?.message ?? error.localizedDescription
                showAlert = true
                print("Validation", error.localizedDescription)
            }
        }
    }
    
  
    
}

#Preview {
    IncidentCreationView()
        .environmentObject(IncidentsStore(client: IncidentsClientMock()))
}


struct IncidentPrioritySelector: View {
    @Binding var selection: KBIncident.Priority?
    var body: some View {
        HStack(spacing: 15) {
            ForEach(KBIncident.Priority.allCases, id: \.self) { priority in
                PriorityCapsuleView(priority: priority, isActive: selection == priority)
                    .contentShape(.capsule)
                    .onTapGesture {
                        withAnimation {
                            selection = priority
                        }
                    }
            }
        }
    }
}

struct PriorityCapsuleView: View {
    let priority: KBIncident.Priority
    let isActive: Bool
    var body: some View {
        let tintColor = priority.getColor()
        Text(priority.rawValue)
            .font(.system(size: 13))
            .foregroundStyle(isActive ? .white : tintColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isActive ? tintColor : .clear, in: .capsule)
            .overlay {
                Capsule()
                    .strokeBorder(tintColor, lineWidth: 1.0)
            }
    }
}

struct IncidentCategorySelector: View {
    @Binding var selection: KBIncident.Category?
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Text(selection?.formatted ?? "Select incident Category")
                    .foregroundStyle(selection ==  nil ? .secondLabel : .accent)
                Spacer()
                
                Image(systemName: "chevron.up")
                    .rotationEffect(.degrees(isExpanded ? 0 : 180))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.shadow(.drop(color: .black.opacity(0.10), radius: 14, x: 0, y: 4)), in: .rect(cornerRadius: 8.0))
            .contentShape(.rect)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading) {
                    ForEach(KBIncident.Category.allCases, id: \.self) { category in
                        
                        Text(category.formatted)
                            .fontWeight(.light)
                            .foregroundStyle(category == selection ? .accent : .primary)
                            .padding(.vertical, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation {
                                    selection = category
                                    isExpanded = false
                                }
                            }
                    }
                }
                .padding()
                .background(
                    .background.shadow(
                        .drop(color: .black.opacity(0.10),
                              radius: 14,
                              x: 0,
                              y: 4)
                    ),
                    in: .rect(cornerRadius: 8.0)
                )
                
            }
        }
    }
}

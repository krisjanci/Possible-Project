import SwiftUI

struct InterviewPrepView: View {
    @Bindable var store: WorkspaceStore
    @State private var selectedApplicationID: UUID?
    @State private var jobDescription = ""
    @State private var result = ""
    @State private var isGenerating = false
    private let intelligence = IntelligenceService()

    private var selectedApplication: JobApplication? {
        store.applications.first { $0.id == selectedApplicationID } ?? store.applications.first
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Card {
                VStack(alignment: .leading, spacing: 16) {
                    SectionLabel(text: "On-device interview coach")
                    Text("Build a focused prep plan").font(.title2.bold())
                    Text("Choose an application and add the job description. Apple Intelligence analyzes it on this Mac.").font(.system(size: 11)).foregroundStyle(Theme.muted).lineSpacing(3)
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Application").font(.caption.weight(.semibold))
                        Picker("Application", selection: $selectedApplicationID) {
                            ForEach(store.applications) { app in Text("\(app.company) · \(app.role)").tag(Optional(app.id)) }
                        }.labelsHidden().frame(maxWidth: .infinity)
                    }
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Job description").font(.caption.weight(.semibold))
                        TextEditor(text: $jobDescription).font(.system(size: 11)).lineSpacing(3).frame(minHeight: 250)
                            .padding(8).background(.white).clipShape(.rect(cornerRadius: 8)).overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))
                    }
                    Button {
                        Task { await generate() }
                    } label: {
                        HStack {
                            if isGenerating { ProgressView().controlSize(.small) } else { Image(systemName: "apple.intelligence") }
                            Text(isGenerating ? "Creating your prep plan…" : "Generate interview prep")
                        }
                        .font(.caption.weight(.bold)).frame(maxWidth: .infinity).frame(height: 40)
                    }
                    .buttonStyle(.borderedProminent).tint(Theme.green).disabled(isGenerating || jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Label("Processed by Apple Foundation Models on this Mac", systemImage: "lock.fill").font(.system(size: 9)).foregroundStyle(Theme.muted).frame(maxWidth: .infinity)
                }
            }
            .frame(width: 390)

            Card {
                if result.isEmpty {
                    ContentUnavailableView("Your prep plan will appear here", systemImage: "sparkles", description: Text("You’ll get role-specific focus areas, questions, and stories to prepare."))
                        .frame(maxWidth: .infinity, minHeight: 510)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    SectionLabel(text: "Prep plan · \(selectedApplication?.company ?? "Application")")
                                    Text(selectedApplication?.role ?? "Interview").font(.title2.bold())
                                }
                                Spacer()
                                Image(systemName: "apple.intelligence").font(.title2).foregroundStyle(Theme.green)
                            }
                            Divider()
                            Text(result).font(.system(size: 12)).lineSpacing(6).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(minHeight: 510)
                }
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 34).padding(.bottom, 34)
        .onAppear {
            if selectedApplicationID == nil { selectedApplicationID = store.applications.first?.id }
            loadDescription()
        }
        .onChange(of: selectedApplicationID) { _, _ in loadDescription() }
    }

    @MainActor
    private func generate() async {
        guard let application = selectedApplication else { return }
        isGenerating = true
        result = await intelligence.interviewPrep(for: application, description: jobDescription)
        isGenerating = false
    }

    private func loadDescription() {
        guard let application = selectedApplication, !application.jobDescription.isEmpty else { return }
        jobDescription = application.jobDescription
    }
}

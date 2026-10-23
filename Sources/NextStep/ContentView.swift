import SwiftUI

struct ContentView: View {
    @Bindable var store: WorkspaceStore
    @State private var showingAddApplication = false

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 250)
        } detail: {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    Group {
                        switch store.selectedSection {
                        case .overview: OverviewView(store: store)
                        case .applications: ApplicationsView(store: store)
                        case .applying: ApplyingView(store: store)
                        case .networking: NetworkingView(store: store)
                        case .prep: InterviewPrepView(store: store)
                        case .integrations: IntegrationsView(store: store)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingAddApplication) {
            AddApplicationView(store: store)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("N")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Theme.green)
                    .clipShape(.rect(cornerRadius: 9))
                Text("NextStep").font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)
            .padding(.bottom, 34)

            VStack(alignment: .leading, spacing: 16) {
                navGroup("Workspace", sections: [.overview])
                navGroup("Job search", sections: [.applications, .applying])
                navGroup("Prepare", sections: [.networking, .prep])
                navGroup("Settings", sections: [.integrations])
            }
            .padding(.horizontal, 10)

            Spacer()

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.shield.fill").foregroundStyle(Theme.green)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Local intelligence").font(.caption.weight(.semibold))
                    Text("Your prep stays on this Mac").font(.system(size: 9)).foregroundStyle(Theme.muted)
                }
            }
            .padding(12)
            .background(Theme.greenSoft.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(12)

            Divider().padding(.horizontal, 16)
            HStack(spacing: 10) {
                Text("AJ").font(.caption2.weight(.bold)).foregroundStyle(.white)
                    .frame(width: 34, height: 34).background(Color(hex: "#A16E57")).clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Alex Johnson").font(.caption.weight(.semibold))
                    Text("Student plan").font(.system(size: 9)).foregroundStyle(Theme.muted)
                }
            }
            .padding(16)
        }
        .background(Color(red: 0.985, green: 0.99, blue: 0.978))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if store.selectedSection == .overview {
                    Text("Good evening, Alex").font(.system(size: 11, weight: .semibold)).foregroundStyle(Theme.green)
                }
                Text(store.selectedSection.rawValue)
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                Text(sectionDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
            if [.overview, .applications, .applying].contains(store.selectedSection) {
                Button { showingAddApplication = true } label: {
                    Label("Add application", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 15).frame(height: 40)
                }
                .buttonStyle(.borderedProminent).tint(Theme.green)
            }
        }
        .padding(.horizontal, 34)
        .frame(height: 118)
    }

    private var sectionDescription: String {
        switch store.selectedSection {
        case .overview: "\(store.activeApplications) active applications · \(store.interviewCount) interview · 2 actions due"
        case .applications: "Track every opportunity and keep the next step clear."
        case .applying: "Turn saved roles into strong, intentional applications."
        case .networking: "Remember who to contact, why, and when to follow up."
        case .prep: "Build focused preparation from the actual job description."
        case .integrations: "Choose which services can contribute recruiting signals."
        }
    }

    @ViewBuilder
    private func navGroup(_ title: String, sections: [WorkspaceSection]) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Theme.muted.opacity(0.75))
                .padding(.horizontal, 13)
                .padding(.bottom, 2)
            ForEach(sections) { section in
                Button {
                    store.selectedSection = section
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: section.symbol).frame(width: 20)
                        Text(section.rawValue)
                        Spacer()
                        if section == .applications {
                            Text("\(store.applications.count)")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(.white.opacity(0.8)).clipShape(Capsule())
                        }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(store.selectedSection == section ? Theme.greenDark : Theme.muted)
                    .padding(.horizontal, 13)
                    .frame(height: 40)
                    .background(store.selectedSection == section ? Theme.greenSoft : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
                .help(section.rawValue)
            }
        }
    }
}

struct AddApplicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: WorkspaceStore
    @State private var company = ""
    @State private var role = ""
    @State private var stage: ApplicationStage = .saved
    @State private var deadline = Date.now.addingTimeInterval(60 * 60 * 24 * 30)
    @State private var description = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    SectionLabel(text: "New opportunity")
                    Text("Add an application").font(.title2.bold())
                }
                Spacer()
                Button("Cancel") { dismiss() }.buttonStyle(.plain).foregroundStyle(Theme.muted)
            }
            HStack {
                field("Company", text: $company, prompt: "Company name")
                field("Role", text: $role, prompt: "Role title")
            }
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Stage").font(.caption.weight(.semibold))
                    Picker("Stage", selection: $stage) { ForEach(ApplicationStage.allCases) { Text($0.rawValue).tag($0) } }
                        .labelsHidden()
                }
                Spacer()
                DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
            }
            VStack(alignment: .leading, spacing: 7) {
                Text("Job description").font(.caption.weight(.semibold))
                TextEditor(text: $description).font(.system(size: 12)).frame(height: 120)
                    .padding(7).background(.white).clipShape(.rect(cornerRadius: 8)).overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))
            }
            HStack {
                Spacer()
                Button("Add application") {
                    store.add(.init(company: company, role: role, stage: stage, deadline: deadline, nextStep: "Review role requirements", jobDescription: description, tintHex: "#4F7468"))
                    dismiss()
                }
                .buttonStyle(.borderedProminent).tint(Theme.green).disabled(company.isEmpty || role.isEmpty)
            }
        }
        .padding(28).frame(width: 610).background(Theme.canvas)
    }

    private func field(_ label: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(.caption.weight(.semibold))
            TextField(prompt, text: text).textFieldStyle(.roundedBorder)
        }
    }
}

struct SettingsView: View {
    @Bindable var store: WorkspaceStore
    var body: some View {
        Form {
            Section("Privacy") {
                LabeledContent("Application storage", value: "On this Mac")
                LabeledContent("Interview preparation", value: "Apple Intelligence")
            }
            Section {
                Button("Reset sample workspace", role: .destructive) { store.reset() }
            }
        }
        .formStyle(.grouped).padding()
    }
}

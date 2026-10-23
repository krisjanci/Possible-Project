import SwiftUI

struct ApplicationsView: View {
    @Bindable var store: WorkspaceStore
    @State private var query = ""
    @State private var filter: ApplicationStage?

    private var filtered: [JobApplication] {
        store.applications.filter { app in
            (query.isEmpty || "\(app.company) \(app.role)".localizedCaseInsensitiveContains(query)) && (filter == nil || app.stage == filter)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Track every opportunity from discovery to decision.").font(.callout).foregroundStyle(Theme.muted)
                Spacer()
                TextField("Search applications", text: $query).textFieldStyle(.roundedBorder).frame(width: 220)
                Picker("Stage", selection: $filter) {
                    Text("All stages").tag(nil as ApplicationStage?)
                    ForEach(ApplicationStage.allCases) { Text($0.rawValue).tag(Optional($0)) }
                }.frame(width: 130)
            }
            Card {
                VStack(spacing: 0) {
                    HStack {
                        Text("Company & role").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Stage").frame(width: 130, alignment: .leading)
                        Text("Deadline").frame(width: 105, alignment: .leading)
                        Text("Next step").frame(width: 210, alignment: .leading)
                    }
                    .font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.muted).textCase(.uppercase).padding(.bottom, 10)
                    ForEach(filtered) { application in
                        HStack(spacing: 12) {
                            CompanyMark(application: application)
                            VStack(alignment: .leading, spacing: 3) { Text(application.role).font(.system(size: 12, weight: .semibold)); Text(application.company).font(.system(size: 10)).foregroundStyle(Theme.muted) }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker("Stage", selection: Binding(get: { application.stage }, set: { store.updateStage(for: application.id, to: $0) })) {
                                ForEach(ApplicationStage.allCases) { Text($0.rawValue).tag($0) }
                            }.labelsHidden().frame(width: 130)
                            Text(application.deadline.shortDisplay).font(.system(size: 10)).frame(width: 105, alignment: .leading)
                            Text(application.nextStep).font(.system(size: 10, weight: .medium)).foregroundStyle(Theme.green).frame(width: 210, alignment: .leading)
                        }
                        .padding(.vertical, 13).overlay(alignment: .top) { Divider() }
                    }
                    if filtered.isEmpty { ContentUnavailableView("No applications", systemImage: "magnifyingglass", description: Text("Try another search or filter.")) }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 34).padding(.bottom, 34)
    }
}

struct ApplyingView: View {
    @Bindable var store: WorkspaceStore
    private let roles = [
        ("Atlas Health", "Design Strategy Intern", "91% match", "AH", "#76578A"),
        ("Mosaic", "UX Design Co-op", "86% match", "MO", "#357C83")
    ]
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Card {
                VStack(alignment: .leading, spacing: 0) {
                    SectionLabel(text: "Saved roles")
                    Text("Ready to apply").font(.title3.bold()).padding(.top, 4)
                    ForEach(Array(roles.enumerated()), id: \.offset) { _, role in
                        let alreadyAdded = store.applications.contains { $0.company == role.0 && $0.role == role.1 }
                        HStack(spacing: 12) {
                            Text(role.3).font(.caption.bold()).foregroundStyle(.white).frame(width: 40, height: 40).background(Color(hex: role.4)).clipShape(.rect(cornerRadius: 9))
                            VStack(alignment: .leading, spacing: 3) { Text(role.1).font(.system(size: 12, weight: .semibold)); Text("\(role.0) · \(role.2)").font(.system(size: 10)).foregroundStyle(Theme.muted) }
                            Spacer()
                            Button(alreadyAdded ? "Added" : "Start application") {
                                store.add(.init(company: role.0, role: role.1, stage: .saved, deadline: .now.addingTimeInterval(2_592_000), nextStep: "Tailor resume and portfolio", jobDescription: "", tintHex: role.4))
                            }.buttonStyle(.bordered).controlSize(.small).disabled(alreadyAdded)
                        }
                        .padding(.vertical, 16).overlay(alignment: .top) { Divider() }
                    }
                }
            }.frame(maxWidth: .infinity)
            Card {
                VStack(alignment: .leading, spacing: 18) {
                    SectionLabel(text: "Application quality")
                    Text("Before you submit").font(.title3.bold())
                    HStack(alignment: .lastTextBaseline, spacing: 6) { Text("82").font(.system(size: 50, weight: .bold, design: .rounded)).foregroundStyle(Theme.green); Text("/ 100\nStrong match").font(.caption).foregroundStyle(Theme.muted) }
                    ChecklistRow(text: "Resume tailored to the role", complete: true)
                    ChecklistRow(text: "Portfolio projects selected", complete: true)
                    ChecklistRow(text: "Cover note reviewed", complete: false)
                    ChecklistRow(text: "Referral requested", complete: false)
                    Button("Find a connection") { store.selectedSection = .networking }.buttonStyle(.borderedProminent).tint(Theme.green).frame(maxWidth: .infinity)
                }
            }.frame(width: 330)
            Spacer()
        }
        .padding(.horizontal, 34).padding(.bottom, 34)
    }
}

private struct ChecklistRow: View {
    var text: String; var complete: Bool
    var body: some View { HStack(spacing: 10) { Image(systemName: complete ? "checkmark.square.fill" : "square").foregroundStyle(complete ? Theme.green : Theme.muted); Text(text).font(.system(size: 11)) } }
}

struct NetworkingView: View {
    @Bindable var store: WorkspaceStore
    @State private var showingAddContact = false
    let columns = [GridItem(.adaptive(minimum: 250), spacing: 14)]
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    Text("Keep context with every relationship so follow-ups feel natural.").font(.system(size: 11)).foregroundStyle(Theme.muted)
                    Spacer()
                    Button { showingAddContact = true } label: { Label("Add contact", systemImage: "person.badge.plus") }
                        .buttonStyle(.borderedProminent).tint(Theme.green).controlSize(.small)
                }
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(store.contacts) { contact in
                        Card {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(spacing: 11) {
                                    Text(contact.initials).font(.caption.bold()).foregroundStyle(.white).frame(width: 42, height: 42).background(Color(hex: contact.tintHex)).clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 3) { Text(contact.name).font(.system(size: 12, weight: .semibold)); Text("\(contact.title) at \(contact.company)").font(.system(size: 9)).foregroundStyle(Theme.muted) }
                                }
                                SectionLabel(text: "How you know them").padding(.top, 3)
                                Text(contact.context).font(.system(size: 11))
                                Divider()
                                HStack { Text("Follow up").font(.caption).foregroundStyle(Theme.muted); Spacer(); Text(contact.followUp.shortDisplay).font(.caption.weight(.semibold)).foregroundStyle(Theme.green) }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 34).padding(.bottom, 34)
        }
        .sheet(isPresented: $showingAddContact) { AddContactView(store: store) }
    }
}

private struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: WorkspaceStore
    @State private var name = ""
    @State private var title = ""
    @State private var company = ""
    @State private var context = ""
    @State private var followUp = Date.now.addingTimeInterval(86_400)

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) { SectionLabel(text: "New relationship"); Text("Add a contact").font(.title2.bold()) }
                Spacer(); Button("Cancel") { dismiss() }.buttonStyle(.plain).foregroundStyle(Theme.muted)
            }
            HStack { field("Name", text: $name, prompt: "Full name"); field("Company", text: $company, prompt: "Company") }
            field("Role", text: $title, prompt: "Job title")
            field("How you know them", text: $context, prompt: "Alumni, event, introduction…")
            DatePicker("Follow up", selection: $followUp, displayedComponents: .date)
            HStack { Spacer(); Button("Add contact") { store.add(.init(name: name, title: title, company: company, context: context, followUp: followUp, tintHex: "#557B72")); dismiss() }.buttonStyle(.borderedProminent).tint(Theme.green).disabled(name.isEmpty || company.isEmpty) }
        }
        .padding(28).frame(width: 540).background(Theme.canvas)
    }

    private func field(_ label: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 7) { Text(label).font(.caption.weight(.semibold)); TextField(prompt, text: text).textFieldStyle(.roundedBorder) }
    }
}

struct IntegrationsView: View {
    @Bindable var store: WorkspaceStore
    @State private var selectedProvider = ""
    @State private var showingPreview = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Bring signals together while keeping you in control.").foregroundStyle(Theme.muted)
                Spacer()
                Text("PROTOTYPE CONNECTIONS").font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(.orange).padding(.horizontal, 10).padding(.vertical, 6).background(.orange.opacity(0.1)).clipShape(Capsule())
            }
            HStack(alignment: .top, spacing: 15) {
                IntegrationCard(name: "Gmail", symbol: "envelope.fill", tint: .red, description: "Detect interview invitations, requests, rejections, and deadlines from recruiting email.", connected: store.gmailDemoConnected) { selectedProvider = "Gmail"; showingPreview = true }
                IntegrationCard(name: "LinkedIn", symbol: "person.crop.square", tint: .blue, description: "Bring in saved roles, application activity, and professional connections.", connected: store.linkedInDemoConnected) { selectedProvider = "LinkedIn"; showingPreview = true }
                IntegrationCard(name: "Apple Intelligence", symbol: "apple.intelligence", tint: Theme.ink, description: "Generate interview preparation with Apple’s on-device Foundation Models framework.", connected: true) {}
            }
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "info.circle.fill").foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Integration boundary").font(.caption.weight(.semibold))
                    Text("Gmail needs OAuth client credentials and a secure token service. LinkedIn data access requires an approved LinkedIn developer application. This build uses safe demo signals and never opens or reads either account.").font(.system(size: 10)).foregroundStyle(Theme.muted)
                }
                Spacer()
            }
            .padding(16).background(.orange.opacity(0.07)).clipShape(.rect(cornerRadius: 10)).overlay(RoundedRectangle(cornerRadius: 10).stroke(.orange.opacity(0.18)))
            Spacer()
        }
        .padding(.horizontal, 34).padding(.bottom, 34)
        .alert("Connect \(selectedProvider) demo", isPresented: $showingPreview) {
            Button("Cancel", role: .cancel) {}
            Button("Use demo data") { store.connectDemo(selectedProvider) }
        } message: {
            Text("This previews the integration with sample recruiting activity. No login opens and no real account data is accessed.")
        }
    }
}

private struct IntegrationCard: View {
    var name: String; var symbol: String; var tint: Color; var description: String; var connected: Bool; var action: () -> Void
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 17) {
                Image(systemName: symbol).font(.title2).foregroundStyle(.white).frame(width: 44, height: 44).background(tint).clipShape(.rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 7) { Text(name).font(.headline); Text(description).font(.system(size: 10)).foregroundStyle(Theme.muted).lineSpacing(3).fixedSize(horizontal: false, vertical: true) }
                Divider()
                Label("You approve every update", systemImage: "checkmark").font(.system(size: 9)).foregroundStyle(Theme.muted)
                Button(connected ? "Connected" : "Connect \(name)", action: action).buttonStyle(.bordered).disabled(connected).frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

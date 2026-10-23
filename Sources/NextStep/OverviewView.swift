import SwiftUI

struct OverviewView: View {
    @Bindable var store: WorkspaceStore
    @State private var syncMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("2 things need your attention").font(.system(size: 13, weight: .semibold))
                        Text("Reply to Northstar today, then prepare your BrightPath portfolio walkthrough.").font(.system(size: 10)).foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    Button("Review applications") { store.selectedSection = .applications }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(16)
                .background(.orange.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(.orange.opacity(0.16)))

                HStack(spacing: 14) {
                    MetricCard(title: "Active applications", value: "\(store.activeApplications)", detail: "+1 this week", symbol: "briefcase", tint: Theme.green)
                    MetricCard(title: "Interviews", value: "\(store.interviewCount)", detail: "Next: Oct 28", symbol: "sparkles", tint: .blue)
                    MetricCard(title: "Network contacts", value: "\(store.contacts.count)", detail: "2 follow-ups due", symbol: "person.2", tint: .orange)
                    MetricCard(title: "Tasks completed", value: "6/9", detail: "67% this week", symbol: "checkmark", tint: .purple)
                }
                HStack(alignment: .top, spacing: 16) {
                    Card {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) { SectionLabel(text: "Pipeline"); Text("Applications").font(.title3.bold()) }
                                Spacer()
                                Button("View all") { store.selectedSection = .applications }.buttonStyle(.plain).foregroundStyle(Theme.green).font(.caption.weight(.semibold))
                            }
                            ForEach(store.applications.prefix(4)) { application in
                                ApplicationRow(application: application, store: store)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 16) {
                        NextActionCard(store: store)
                        Card {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("Recent updates").font(.headline)
                                    Spacer()
                                    Button { syncMessage = store.syncDemoEmail() } label: { Label("Check demo inbox", systemImage: "arrow.clockwise") }
                                        .buttonStyle(.plain).font(.caption.weight(.semibold)).foregroundStyle(Theme.green)
                                }
                                ForEach(store.activities.prefix(3)) { activity in
                                    HStack(alignment: .top, spacing: 11) {
                                        Image(systemName: activity.symbol).font(.caption).foregroundStyle(Theme.green)
                                            .frame(width: 28, height: 28).background(Theme.greenSoft).clipShape(Circle())
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(activity.message).font(.system(size: 11, weight: .medium)).fixedSize(horizontal: false, vertical: true)
                                            Text("\(activity.source) · \(activity.date.relativeDisplay)").font(.system(size: 9)).foregroundStyle(Theme.muted)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    Divider()
                                }
                                Text("Demo inbox data · No real email is read").font(.system(size: 8)).foregroundStyle(Theme.muted).frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(width: 320)
                }
            }
            .padding(.horizontal, 34).padding(.bottom, 34)
        }
        .alert("Email sync", isPresented: Binding(get: { !syncMessage.isEmpty }, set: { if !$0 { syncMessage = "" } })) {
            Button("OK", role: .cancel) { syncMessage = "" }
        } message: { Text(syncMessage) }
    }
}

private struct MetricCard: View {
    var title: String; var value: String; var detail: String; var symbol: String; var tint: Color
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                HStack { Text(title).font(.system(size: 11, weight: .medium)).foregroundStyle(Theme.muted); Spacer(); Image(systemName: symbol).foregroundStyle(tint).frame(width: 28, height: 28).background(tint.opacity(0.1)).clipShape(.rect(cornerRadius: 7)) }
                Text(value).font(.system(size: 28, weight: .bold, design: .rounded))
                Text(detail).font(.system(size: 9)).foregroundStyle(Theme.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ApplicationRow: View {
    var application: JobApplication
    @Bindable var store: WorkspaceStore
    var body: some View {
        HStack(spacing: 12) {
            CompanyMark(application: application)
            VStack(alignment: .leading, spacing: 3) {
                Text(application.role).font(.system(size: 12, weight: .semibold)).lineLimit(1)
                Text(application.company).font(.system(size: 10)).foregroundStyle(Theme.muted)
            }
            .frame(minWidth: 145, maxWidth: .infinity, alignment: .leading)
            Spacer()
            StageBadge(stage: application.stage).frame(width: 82)
            VStack(alignment: .leading, spacing: 3) {
                Text(application.nextStep).font(.system(size: 10, weight: .medium)).lineLimit(1)
                Text(application.updatedAt.relativeDisplay).font(.system(size: 9)).foregroundStyle(Theme.muted)
            }
            .frame(width: 145, alignment: .leading)
            Menu { ForEach(ApplicationStage.allCases) { stage in Button(stage.rawValue) { store.updateStage(for: application.id, to: stage) } } } label: {
                Image(systemName: "ellipsis").foregroundStyle(Theme.muted)
            }
            .menuStyle(.borderlessButton).frame(width: 20)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .top) { Divider() }
    }
}

private struct NextActionCard: View {
    @Bindable var store: WorkspaceStore
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "✦ Next best action", color: Color(red: 0.73, green: 0.91, blue: 0.60))
            Text("BrightPath · Product Design Intern").font(.system(size: 9)).foregroundStyle(.white.opacity(0.55)).padding(.top, 24)
            Text("Prepare three portfolio talking points").font(.system(size: 21, weight: .bold, design: .rounded)).foregroundStyle(.white).padding(.top, 7)
            Text("Why now: your interview invitation asks for a walkthrough of one recent project.").font(.system(size: 11)).foregroundStyle(.white.opacity(0.7)).lineSpacing(3).padding(.top, 10)
            HStack { Label("Due tomorrow", systemImage: "calendar"); Label("15 min", systemImage: "clock") }
                .font(.system(size: 9)).foregroundStyle(.white.opacity(0.7)).padding(.top, 18)
            Button {
                store.actionCompleted.toggle(); store.save()
            } label: {
                Label(store.actionCompleted ? "Task completed" : "Mark task done", systemImage: "checkmark")
                    .font(.caption.weight(.bold)).frame(maxWidth: .infinity).frame(height: 38)
            }
            .buttonStyle(.plain)
            .foregroundStyle(store.actionCompleted ? .white : Theme.greenDark)
            .background(store.actionCompleted ? .white.opacity(0.12) : Color(red: 0.80, green: 0.92, blue: 0.56))
            .clipShape(.rect(cornerRadius: 8)).padding(.top, 20)
        }
        .padding(24).background(Theme.greenDark).clipShape(.rect(cornerRadius: 14))
    }
}

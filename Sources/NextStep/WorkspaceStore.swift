import Foundation
import Observation

@MainActor
@Observable
final class WorkspaceStore {
    var applications: [JobApplication] = []
    var contacts: [NetworkContact] = []
    var activities: [ActivityItem] = []
    var selectedSection: WorkspaceSection = .overview
    var gmailDemoConnected = false
    var linkedInDemoConnected = false
    var actionCompleted = false

    private let defaultsKey = "nextstep.workspace.v3"

    init() {
        load()
    }

    var activeApplications: Int { applications.filter { $0.stage != .offer && $0.stage != .saved }.count }
    var interviewCount: Int { applications.filter { $0.stage == .interview }.count }

    func add(_ application: JobApplication) {
        applications.insert(application, at: 0)
        activities.insert(.init(symbol: "plus", message: "Added \(application.company) to your pipeline", source: "NextStep"), at: 0)
        save()
    }

    func add(_ contact: NetworkContact) {
        contacts.insert(contact, at: 0)
        activities.insert(.init(symbol: "person.badge.plus", message: "Added \(contact.name) to your network", source: "NextStep"), at: 0)
        save()
    }

    func updateStage(for id: UUID, to stage: ApplicationStage) {
        guard let index = applications.firstIndex(where: { $0.id == id }) else { return }
        applications[index].stage = stage
        applications[index].updatedAt = .now
        applications[index].nextStep = nextStep(for: stage)
        activities.insert(.init(symbol: "arrow.triangle.2.circlepath", message: "\(applications[index].company) moved to \(stage.rawValue)", source: "Manual update"), at: 0)
        save()
    }

    func connectDemo(_ provider: String) {
        if provider == "Gmail" { gmailDemoConnected = true }
        if provider == "LinkedIn" { linkedInDemoConnected = true }
        save()
    }

    func syncDemoEmail() -> String {
        guard gmailDemoConnected else { return "Connect the Gmail demo in Integrations first." }
        guard let index = applications.firstIndex(where: { $0.company == "BrightPath" }) else { return "No matching application found." }
        if activities.contains(where: { $0.message.contains("portfolio presentation brief") }) {
            return "Everything is already up to date."
        }
        applications[index].stage = .interview
        applications[index].nextStep = "Review portfolio presentation brief"
        applications[index].updatedAt = .now
        activities.insert(.init(symbol: "envelope.badge", message: "BrightPath sent a portfolio presentation brief", source: "Gmail demo"), at: 0)
        save()
        return "BrightPath updated to Interview. A new next step was added."
    }

    func save() {
        let snapshot = Snapshot(applications: applications, contacts: contacts, activities: activities, gmailDemoConnected: gmailDemoConnected, linkedInDemoConnected: linkedInDemoConnected, actionCompleted: actionCompleted)
        if let data = try? JSONEncoder().encode(snapshot) { UserDefaults.standard.set(data, forKey: defaultsKey) }
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        seed()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey), let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            seed(); return
        }
        applications = snapshot.applications
        contacts = snapshot.contacts
        activities = snapshot.activities
        gmailDemoConnected = snapshot.gmailDemoConnected
        linkedInDemoConnected = snapshot.linkedInDemoConnected
        actionCompleted = snapshot.actionCompleted
    }

    private func seed() {
        let calendar = Calendar.current
        let day: (Int) -> Date = { offset in calendar.date(byAdding: .day, value: offset, to: .now) ?? .now }
        applications = [
            .init(company: "BrightPath", role: "Product Design Intern", stage: .interview, deadline: day(24), nextStep: "Prepare portfolio walkthrough", jobDescription: "Translate customer insights into intuitive product experiences. Collaborate with product managers and engineers, create prototypes in Figma, contribute to user research, and present design decisions.", tintHex: "#246B52"),
            .init(company: "Northstar", role: "UX Research Intern", stage: .screening, deadline: day(17), nextStep: "Reply with availability", jobDescription: "Plan user interviews, synthesize qualitative research, communicate insights, and partner with product teams.", tintHex: "#45658D"),
            .init(company: "Common Ground", role: "Product Intern", stage: .applied, deadline: day(29), nextStep: "Follow up next week", jobDescription: "Support product strategy, analyze customer feedback, define requirements, and coordinate cross-functional launches.", tintHex: "#936341")
        ]
        contacts = [
            .init(name: "Maya Chen", title: "Product Designer", company: "BrightPath", context: "Alumni from your design program", followUp: day(1), tintHex: "#A86652"),
            .init(name: "Daniel Ross", title: "UX Researcher", company: "Northstar", context: "Met at Campus Design Night", followUp: day(2), tintHex: "#527495"),
            .init(name: "Priya Shah", title: "Associate PM", company: "Common Ground", context: "Second-degree connection", followUp: day(5), tintHex: "#6F8861"),
            .init(name: "Jordan Lee", title: "Recruiter", company: "BrightPath", context: "Sent your interview invitation", followUp: day(4), tintHex: "#886579")
        ]
        activities = [
            .init(symbol: "envelope", message: "Interview invitation detected from BrightPath", date: day(0), source: "Demo inbox"),
            .init(symbol: "calendar", message: "Northstar requested your availability", date: day(-1), source: "Demo inbox"),
            .init(symbol: "checkmark", message: "Resume marked ready for Common Ground", date: day(-3), source: "NextStep")
        ]
        gmailDemoConnected = false
        linkedInDemoConnected = false
        actionCompleted = false
        save()
    }

    private func nextStep(for stage: ApplicationStage) -> String {
        switch stage {
        case .saved: "Tailor resume and portfolio"
        case .applied: "Plan a thoughtful follow-up"
        case .screening: "Prepare your 60-second introduction"
        case .interview: "Build an interview prep plan"
        case .offer: "Review the offer and questions"
        }
    }
}

private struct Snapshot: Codable {
    var applications: [JobApplication]
    var contacts: [NetworkContact]
    var activities: [ActivityItem]
    var gmailDemoConnected: Bool
    var linkedInDemoConnected: Bool
    var actionCompleted: Bool
}

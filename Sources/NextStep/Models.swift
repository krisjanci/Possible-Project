import Foundation
import SwiftUI

enum ApplicationStage: String, Codable, CaseIterable, Identifiable {
    case saved = "Saved"
    case applied = "Applied"
    case screening = "Screening"
    case interview = "Interview"
    case offer = "Offer"

    var id: String { rawValue }
    var color: Color {
        switch self {
        case .saved: .orange
        case .applied: .green
        case .screening: .blue
        case .interview: .purple
        case .offer: .yellow
        }
    }
}

struct JobApplication: Identifiable, Codable, Hashable {
    var id = UUID()
    var company: String
    var role: String
    var stage: ApplicationStage
    var deadline: Date
    var nextStep: String
    var jobDescription: String
    var updatedAt: Date = .now
    var tintHex: String

    var initials: String {
        company.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }
}

struct NetworkContact: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var title: String
    var company: String
    var context: String
    var followUp: Date
    var tintHex: String

    var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }
}

struct ActivityItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var symbol: String
    var message: String
    var date: Date = .now
    var source: String
}

enum WorkspaceSection: String, CaseIterable, Identifiable {
    case overview = "Today"
    case applications = "Applications"
    case applying = "Applying"
    case networking = "Networking"
    case prep = "Interview Prep"
    case integrations = "Integrations"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .applications: "briefcase"
        case .applying: "paperplane"
        case .networking: "person.2"
        case .prep: "sparkles"
        case .integrations: "link"
        }
    }
}

extension Color {
    init(hex: String) {
        let value = UInt64(hex.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0x246B52
        self.init(
            red: Double((value >> 16) & 0xff) / 255,
            green: Double((value >> 8) & 0xff) / 255,
            blue: Double(value & 0xff) / 255
        )
    }
}

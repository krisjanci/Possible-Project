import SwiftUI

enum Theme {
    static let canvas = Color(red: 0.965, green: 0.969, blue: 0.953)
    static let surface = Color.white
    static let ink = Color(red: 0.09, green: 0.13, blue: 0.11)
    static let muted = Color(red: 0.43, green: 0.48, blue: 0.45)
    static let green = Color(red: 0.14, green: 0.42, blue: 0.32)
    static let greenDark = Color(red: 0.08, green: 0.29, blue: 0.22)
    static let greenSoft = Color(red: 0.89, green: 0.94, blue: 0.91)
    static let border = Color.black.opacity(0.08)
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(22)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.border))
            .shadow(color: .black.opacity(0.025), radius: 16, y: 6)
    }
}

struct SectionLabel: View {
    var text: String
    var color: Color = Theme.green
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(1.5)
            .foregroundStyle(color)
    }
}

struct CompanyMark: View {
    var application: JobApplication
    var size: CGFloat = 40
    var body: some View {
        Text(application.initials)
            .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Color(hex: application.tintHex))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.23, style: .continuous))
    }
}

struct StageBadge: View {
    var stage: ApplicationStage
    var body: some View {
        Text(stage.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(stage.color)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(stage.color.opacity(0.11))
            .clipShape(Capsule())
    }
}

extension Date {
    var shortDisplay: String { formatted(.dateTime.month(.abbreviated).day()) }
    var relativeDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}

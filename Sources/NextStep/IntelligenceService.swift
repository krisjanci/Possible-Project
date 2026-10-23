import Foundation
import FoundationModels

struct IntelligenceService {
    func interviewPrep(for application: JobApplication, description: String) async -> String {
        let prompt = """
        Create a concise interview preparation plan for this opportunity.

        Company: \(application.company)
        Role: \(application.role)
        Job description: \(description)

        Return plain text with exactly these sections:
        FOCUS AREAS — four short bullets
        QUESTIONS TO REHEARSE — four realistic interview questions
        STORIES TO PREPARE — three STAR story prompts
        QUESTIONS TO ASK THEM — three thoughtful questions

        Be specific to the job description. Do not invent company facts.
        """

        do {
            let session = LanguageModelSession(instructions: "You are a practical career coach for university students. Be specific, encouraging, and concise.")
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return fallbackPrep(for: application, description: description)
        }
    }

    func analyzeRecruitingEmail(_ email: String, applications: [JobApplication]) async -> String {
        let companies = applications.map(\.company).joined(separator: ", ")
        let prompt = """
        Analyze this recruiting email for a job applicant. Known companies: \(companies).
        Identify the matching company, likely hiring stage, any date or deadline, and one immediate next action.
        If uncertain, say so. Keep the answer under 100 words.

        EMAIL:
        \(email)
        """
        do {
            let session = LanguageModelSession(instructions: "You extract hiring progress and next actions from recruiting messages. Never invent details.")
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Likely update: Interview stage at BrightPath. Next action: review the portfolio presentation brief and confirm attendance. This fallback was generated locally without Apple Intelligence."
        }
    }

    private func fallbackPrep(for application: JobApplication, description: String) -> String {
        let lower = description.lowercased()
        var areas: [String] = []
        let mappings = [("research", "User research"), ("figma", "Figma and prototyping"), ("collabor", "Cross-functional collaboration"), ("communicat", "Clear communication"), ("strategy", "Product strategy"), ("data", "Using data to decide")]
        for (key, label) in mappings where lower.contains(key) { areas.append(label) }
        while areas.count < 4 { areas.append(["Role motivation", "Structured problem solving", "Learning quickly", "Customer empathy"][areas.count]) }
        return """
        FOCUS AREAS
        \(areas.prefix(4).map { "• \($0)" }.joined(separator: "\n"))

        QUESTIONS TO REHEARSE
        • Walk me through a project that best represents your process.
        • Tell me about a difficult cross-functional decision.
        • How do you turn ambiguous feedback into a clear direction?
        • Why \(application.company), and why this role?

        STORIES TO PREPARE
        • A project with measurable impact
        • A time research changed your direction
        • A thoughtful failure and what you learned

        QUESTIONS TO ASK THEM
        • What would strong performance look like in the first 60 days?
        • How does the team make and critique decisions?
        • What kinds of projects would an intern own?

        Generated with the built-in local fallback because Apple Intelligence was unavailable.
        """
    }
}

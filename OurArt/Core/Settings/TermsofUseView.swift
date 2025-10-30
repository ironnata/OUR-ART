//
//  TermsofUseView.swift
//  OurArt
//
//  Created by Jongmo You on 29.08.25.
//

import SwiftUI

struct TermsofUseView: View {
    @State private var text = """
             Effective Date: [Insert Date]
             Contact: dotbymo@gmail.com

             ⸻

             1. Acceptance of Terms

             By downloading or using the DOT app (“App”), you agree to be bound by these Terms of Use.
             If you do not agree, please do not use the App.

             ⸻

             2. Eligibility

             You must be at least 13 years old to use the App.
             By using the App, you confirm that you meet this requirement.

             ⸻

             3. Accounts

             You may sign in using Google, Apple, or use the App anonymously.
             You are responsible for keeping your account information secure.

             ⸻

             4. User Content

             Users may upload or edit exhibition-related information.
             You are responsible for any content you submit, and you must have the rights to share it.
             You retain ownership of the content you upload to Dot.
             By posting, you grant us a non-exclusive right to display your content within the App.
             Inappropriate, harmful, or illegal content may be removed without notice.

             ⸻

             5. Prohibited Conduct

             You agree not to:
                 •    Violate any laws or regulations
                 •    Post harmful, offensive, or misleading content
                 •    Attempt to disrupt or misuse the App

             ⸻

             6. Intellectual Property

             All rights in the App, including design, features, and content created by DOT, remain the property of the developer.
             You may not copy, modify, or distribute the App without permission.

             ⸻

             7. Third-Party Services & External Links

             The App may include links or services from third parties (such as Firebase or AdMob).
             We are not responsible for their content, accuracy, or policies.
             Accessing such services or links is at your own discretion.

             ⸻

             8. Advertising

             The App displays third-party advertisements (via Google AdMob).
             We are not responsible for the content or accuracy of such ads.

             ⸻

             9. Disclaimer

             The App is provided “as is” without warranties of any kind.
             We do not guarantee that the App will always be available, error-free, or meet your expectations.

             ⸻

             10. Limitation of Liability

             To the maximum extent permitted by law, the developer is not responsible for any damages resulting from your use of the App.

             ⸻

             11. Termination

             We may suspend or terminate your access to the App at any time if you violate these Terms.

             ⸻

             12. Changes to Terms

             We may update these Terms from time to time.
             Continued use of the App means you accept the updated Terms.

             ⸻

             13. Governing Law

             These Terms are governed by the laws of Germany.
             Users outside Germany are responsible for compliance with their local laws.

             ⸻

             14. Contact

             If you have questions about these Terms, please contact us:
             📧 dotbymo@gmail.com
             """
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    Text(text)
                        .font(.objectivityFootnote)
                        .padding()
                        .textSelection(.enabled)
                        .lineSpacing(10)
                }
                .toolbar {
                    ToolbarBackButton()
                    
                    ToolbarItem(placement: .principal) {
                        Text("Terms of Use")
                    }
                }
                .toolbarBackground()
            }
            .viewBackground()
        }
    }
}

#Preview {
    TermsofUseView()
}

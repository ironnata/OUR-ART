//
//  PrivacyPolicyView.swift
//  OurArt
//
//  Created by Jongmo You on 29.08.25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @State private var text = """
             Effective Date: [Insert Date]
             
             DOT (“the App,” “we,” “our,” or “us”) values your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.
             
             ⸻
             
             1. Information We Collect
             
             We collect the following types of information when you use the App:
                 • Account Information: If you log in using Apple, Google, or anonymously, we collect the associated account identifier.
                 • User-Generated Content: Information you provide when creating or editing exhibition posts, such as exhibition name, artist, dates, venue (including address), and descriptions.
                 • Device Information: Basic technical details like device type, operating system, and usage logs.
                 • Advertising Data: Information collected via Google AdMob for displaying ads (e.g., ad interactions, impressions).
             
             ⸻
             
             2. How We Use Information
             
             We use the information collected to:
                 • Provide and improve the App’s functionality.
                 • Allow users to create, modify, and delete exhibition posts.
                 • Display relevant advertisements.
                 • Maintain and secure our services.
             
             ⸻
             
             3. Sharing of Information
             
             We do not sell or rent your personal information. We only share information in these cases:
                 • With Service Providers: Such as Firebase (for backend and data storage) and Google AdMob (for ads).
                 • Legal Requirements: When required to comply with applicable laws or protect rights and safety.
             
             ⸻
             
             4. Data Retention
                 • User-generated content (exhibition details) is stored until you delete it.
                 • Account information is retained while your account is active.
                 • We may keep some records to comply with legal obligations.
             
             ⸻
             
             5. User Rights
                 • You may access, update, or delete your exhibition posts at any time.
                 • You may request deletion of your account by contacting us.
                 • You may opt out of personalized ads through your device settings.
             
             ⸻
             
             6. Children’s Privacy
             
             The App is not directed to children under the age of 13. We do not knowingly collect data from children.
             
             ⸻
             
             7. Security
             
             We take reasonable measures to protect your data, but no method of electronic storage is 100% secure.
             
             ⸻
             
             8. Changes to This Policy
             
             We may update this Privacy Policy from time to time. Changes will be posted within the App with the updated “Effective Date.”
             
             ⸻
             
             9. Contact Us
             
             If you have any questions or concerns about this Privacy Policy, please contact us
             📧 dotbymo@gmail.com
             """
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    Text(text)
                        .font(.objectivityFootnote)
                        .padding()
                        .padding(.top, -50)
                        .textSelection(.enabled)
                        .lineSpacing(10)
                }
                .toolbar {
                    ToolbarBackButton()
                    
                    ToolbarItem(placement: .principal) {
                        Text("Privacy Policy")
                    }
                }
                .toolbarBackground()
            }
            .viewBackground()
        }
    }
}

#Preview {
    PrivacyPolicyView()
}

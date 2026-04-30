const TermsAndConditionsPage = () => {
  return (
    <div className="container mx-auto px-4 md:px-8 lg:px-16 py-8 max-w-5xl">
      <div className="bg-white rounded-xl shadow-sm p-6 md:p-10">
        <h1 className="text-3xl md:text-4xl font-bold text-center text-[#002C3F] mb-2">
          Terms and Conditions
        </h1>
        <p className="text-center text-gray-500 mb-8">
          Last Updated: November 15, 2025
        </p>

        <div className="prose prose-slate max-w-none">
          {/* Section 1 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              1. Acceptance of Terms
            </h2>
            <p className="text-gray-700 leading-relaxed">
              By accessing and using the MPC (Midlands Performance Club) mobile
              application ("the App"), you agree to be bound by these Terms and
              Conditions. If you do not agree to these terms, please do not use
              the App.
            </p>
          </section>

          {/* Section 2 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              2. Service Description
            </h2>
            <p className="text-gray-700 leading-relaxed mb-3">
              MPC provides online fitness coaching services including:
            </p>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>Personalized training plans and workout programs</li>
              <li>Nutrition guidance and calorie tracking</li>
              <li>Progress tracking through check-ins and photos</li>
              <li>Direct messaging with your assigned coach</li>
              <li>Workout logging and performance tracking</li>
            </ul>
          </section>

          {/* Section 3 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              3. Subscription and Payment
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              3.1 Subscription Terms
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                The MPC Elite Online Coaching subscription costs €260.00 per
                month
              </li>
              <li>
                Subscriptions automatically renew monthly unless cancelled at
                least 24 hours before the end of the current billing period
              </li>
              <li>
                Payment will be charged to your Apple ID account at confirmation
                of purchase
              </li>
              <li>
                Your account will be charged for renewal within 24 hours prior
                to the end of the current period
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              3.2 Cancellation
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                You may cancel your subscription at any time through your Apple
                ID account settings
              </li>
              <li>
                Cancellation takes effect at the end of the current billing
                period
              </li>
              <li>
                No refunds will be provided for partial months or unused
                portions of the subscription
              </li>
              <li>
                You will retain access to the service until the end of your
                current billing period
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              3.3 Price Changes
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                Subscription prices are subject to change with 30 days' notice
              </li>
              <li>
                Continued use of the service after a price change constitutes
                acceptance of the new price
              </li>
            </ul>
          </section>

          {/* Section 4 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              4. User Account and Registration
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              4.1 Account Creation
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                You must provide accurate and complete information during
                registration
              </li>
              <li>
                You are responsible for maintaining the confidentiality of your
                account credentials
              </li>
              <li>You must be at least 18 years old to use this service</li>
              <li>
                One subscription is valid for one user only and may not be
                shared
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              4.2 Account Security
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                You are solely responsible for all activities under your account
              </li>
              <li>
                Notify us immediately of any unauthorized use of your account
              </li>
              <li>
                We reserve the right to suspend or terminate accounts that
                violate these terms
              </li>
            </ul>
          </section>

          {/* Section 5 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              5. User Responsibilities
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              5.1 Health and Safety
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                Consult with a healthcare professional before beginning any
                fitness program
              </li>
              <li>
                You acknowledge that participation in fitness activities carries
                inherent risks
              </li>
              <li>
                You are solely responsible for determining if the training
                programs are appropriate for your fitness level
              </li>
              <li>
                Immediately discontinue any exercise that causes pain or
                discomfort
              </li>
              <li>
                MPC and its coaches are not responsible for any injuries
                sustained while following the program
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              5.2 Accurate Information
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                Provide accurate health and fitness information to your coach
              </li>
              <li>Update your profile information as changes occur</li>
              <li>
                Disclose any medical conditions, injuries, or limitations that
                may affect your training
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              5.3 Prohibited Conduct
            </h3>
            <p className="text-gray-700 leading-relaxed mb-3">
              You agree not to:
            </p>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>Share your account credentials with others</li>
              <li>Upload inappropriate, offensive, or copyrighted content</li>
              <li>Harass, abuse, or harm other users or coaches</li>
              <li>Use the App for any illegal purposes</li>
              <li>
                Attempt to hack, reverse engineer, or compromise the App's
                security
              </li>
              <li>Upload viruses or malicious code</li>
            </ul>
          </section>

          {/* Section 6 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              6. Content and Intellectual Property
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              6.1 Our Content
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                All training plans, workout programs, educational materials, and
                app content are owned by MPC
              </li>
              <li>
                You may not copy, distribute, modify, or create derivative works
                from our content
              </li>
              <li>
                The MPC name, logo, and trademarks are protected intellectual
                property
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              6.2 User Content
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                You retain ownership of photos, progress updates, and other
                content you upload
              </li>
              <li>
                By uploading content, you grant MPC a license to use, display,
                and store your content for service delivery
              </li>
              <li>
                You represent that you own or have rights to any content you
                upload
              </li>
              <li>
                We reserve the right to remove content that violates these terms
              </li>
            </ul>
          </section>

          {/* Section 7 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              7. Coach-Client Relationship
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              7.1 Professional Services
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                Coaches provide fitness guidance and programming based on their
                expertise
              </li>
              <li>
                The relationship is professional and coaching advice should not
                replace medical advice
              </li>
              <li>
                Response times may vary; coaches will make reasonable efforts to
                respond within 48 hours
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              7.2 Program Modifications
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                Your coach reserves the right to modify training plans based on
                your progress and feedback
              </li>
              <li>
                Programs are personalized but results may vary based on
                individual effort and adherence
              </li>
            </ul>
          </section>

          {/* Section 8 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              8. Limitation of Liability
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              8.1 Service Availability
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                We strive for 99% uptime but do not guarantee uninterrupted
                service
              </li>
              <li>
                We are not liable for service interruptions, technical issues,
                or data loss
              </li>
              <li>
                Scheduled maintenance may temporarily affect service
                availability
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              8.2 Fitness Results
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>We do not guarantee specific fitness results or outcomes</li>
              <li>
                Results depend on individual effort, adherence, genetics, and
                other factors beyond our control
              </li>
              <li>
                Testimonials and success stories represent individual
                experiences and are not typical results
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              8.3 Damages
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                To the maximum extent permitted by law, MPC shall not be liable
                for any indirect, incidental, special, consequential, or
                punitive damages
              </li>
              <li>
                Our total liability shall not exceed the amount paid for your
                subscription in the 12 months preceding the claim
              </li>
            </ul>
          </section>

          {/* Section 9 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              9. Privacy and Data Protection
            </h2>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                Your personal data is processed according to our Privacy Policy
              </li>
              <li>
                We collect health and fitness data necessary to provide coaching
                services
              </li>
              <li>
                We implement reasonable security measures to protect your data
              </li>
              <li>We do not sell your personal information to third parties</li>
            </ul>
          </section>

          {/* Section 10 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              10. Third-Party Services
            </h2>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                The App uses Apple's In-App Purchase system for subscriptions
              </li>
              <li>
                Push notifications are delivered through Firebase Cloud
                Messaging
              </li>
              <li>
                Third-party services have their own terms and privacy policies
              </li>
              <li>
                We are not responsible for third-party service failures or data
                breaches
              </li>
            </ul>
          </section>

          {/* Section 11 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              11. Modifications to Terms
            </h2>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                We reserve the right to modify these Terms and Conditions at any
                time
              </li>
              <li>Changes will be effective upon posting in the App</li>
              <li>
                Continued use after changes constitutes acceptance of modified
                terms
              </li>
              <li>
                Material changes will be communicated via email or in-app
                notification
              </li>
            </ul>
          </section>

          {/* Section 12 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              12. Termination
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              12.1 By You
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                You may terminate your account by cancelling your subscription
                and contacting us
              </li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              12.2 By Us
            </h3>
            <p className="text-gray-700 leading-relaxed mb-3">
              We may suspend or terminate your account if:
            </p>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>You violate these Terms and Conditions</li>
              <li>You engage in fraudulent or illegal activities</li>
              <li>You harass coaches or other users</li>
              <li>Your account remains inactive for 12+ months</li>
              <li>We discontinue the service (with 30 days' notice)</li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              12.3 Effect of Termination
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>Upon termination, your access to the App will cease</li>
              <li>We may delete your data after account termination</li>
              <li>
                No refunds will be provided for early termination by us due to
                violations
              </li>
            </ul>
          </section>

          {/* Section 13 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              13. Dispute Resolution
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              13.1 Governing Law
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>These terms are governed by the laws of Ireland</li>
              <li>Any disputes shall be resolved in the courts of Ireland</li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              13.2 Arbitration
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                For disputes under €5,000, parties agree to attempt mediation
                before litigation
              </li>
              <li>
                Each party bears their own legal costs unless otherwise awarded
              </li>
            </ul>
          </section>

          {/* Section 14 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              14. Indemnification
            </h2>
            <p className="text-gray-700 leading-relaxed mb-3">
              You agree to indemnify and hold harmless MPC, its coaches,
              employees, and affiliates from any claims, damages, or expenses
              arising from:
            </p>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>Your use of the App</li>
              <li>Your violation of these terms</li>
              <li>Your violation of any third-party rights</li>
              <li>Any injuries sustained while following training programs</li>
            </ul>
          </section>

          {/* Section 15 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              15. Miscellaneous
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              15.1 Entire Agreement
            </h3>
            <p className="text-gray-700 leading-relaxed">
              These Terms and Conditions, together with our Privacy Policy,
              constitute the entire agreement between you and MPC.
            </p>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              15.2 Severability
            </h3>
            <p className="text-gray-700 leading-relaxed">
              If any provision is found unenforceable, the remaining provisions
              remain in full effect.
            </p>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              15.3 Waiver
            </h3>
            <p className="text-gray-700 leading-relaxed">
              Failure to enforce any provision does not constitute a waiver of
              that provision.
            </p>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              15.4 Assignment
            </h3>
            <p className="text-gray-700 leading-relaxed">
              You may not assign your rights under these terms. We may assign
              our rights to any successor or affiliate.
            </p>
          </section>

          {/* Section 16 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              16. Contact Information
            </h2>
            <p className="text-gray-700 leading-relaxed mb-3">
              For questions about these Terms and Conditions, please contact us
              at:
            </p>
            <div className="bg-gray-50 p-4 rounded-lg">
              <p className="font-semibold text-[#002C3F] mb-1">
                Midlands Performance Club
              </p>
              <p className="text-gray-700">
                Email:{' '}
                <a
                  href="mailto:info@midlandsperformanceclub.ie"
                  className="text-[#077fb6] hover:underline"
                >
                  shanemahon113@gmail.com
                </a>
              </p>
              <p className="text-gray-700">
                Website:{' '}
                <a
                  href="https://www.midlandsperformanceclub.ie"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#077fb6] hover:underline"
                >
                  www.midlandsperformanceclub.ie
                </a>
              </p>
            </div>
          </section>

          {/* Footer Note */}
          <div className="border-t border-gray-200 pt-6 mt-8">
            <p className="text-sm text-gray-600 text-center italic">
              By clicking "I Accept" or by using the MPC App, you acknowledge
              that you have read, understood, and agree to be bound by these
              Terms and Conditions.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TermsAndConditionsPage;

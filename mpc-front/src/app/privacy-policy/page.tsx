const PrivacyPolicyPage = () => {
  return (
    <div className="container mx-auto px-4 md:px-8 lg:px-16 py-8 max-w-5xl">
      <div className="bg-white rounded-xl shadow-sm p-6 md:p-10">
        <h1 className="text-3xl md:text-4xl font-bold text-center text-[#002C3F] mb-2">
          Privacy Policy
        </h1>
        <p className="text-center text-gray-500 mb-8">
          Last Updated: August 12, 2026
        </p>

        <div className="prose prose-slate max-w-none">
          {/* Section 1 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              1. Introduction
            </h2>
            <p className="text-gray-700 leading-relaxed">
              This Privacy Policy applies to the MPC (Midlands Performance Club)
              mobile application and website ("the Service") operated by
              Midlands Performance Club ("we", "us", "our"). It explains what
              information we collect, how we use it, and the choices you have.
              By using the Service, you agree to the collection and use of
              information in accordance with this policy.
            </p>
          </section>

          {/* Section 2 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              2. Information We Collect
            </h2>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              2.1 Information You Provide
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                Account information: name, email address, and password when you
                register
              </li>
              <li>
                Health and fitness information: age, weight, fitness goals,
                training history, and any medical or injury information you
                choose to share with your coach
              </li>
              <li>
                Check-in data: progress updates, measurements, and photos you
                submit as part of your coaching program
              </li>
              <li>
                Workout data: exercises, sets, reps, weights, and calorie
                information you log in the app
              </li>
              <li>Messages you exchange with your coach through the app</li>
            </ul>

            <h3 className="text-xl font-semibold text-[#002C3F] mb-2 mt-4">
              2.2 Information Collected Automatically
            </h3>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>Device information such as device model and operating system</li>
              <li>
                Usage information such as the features you use and the time and
                date of your visits
              </li>
              <li>IP address and general log data</li>
            </ul>
            <p className="text-gray-700 leading-relaxed mt-3">
              The Service does not collect precise location data from your
              device.
            </p>
          </section>

          {/* Section 3 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              3. How We Use Your Information
            </h2>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                To provide and personalize your coaching service, including
                training plans, nutrition guidance, and progress tracking
              </li>
              <li>To enable communication between you and your coach</li>
              <li>To process subscriptions and payments</li>
              <li>
                To send you service-related notifications, such as check-in
                reminders and coach messages
              </li>
              <li>To maintain, improve, and secure the Service</li>
              <li>To comply with legal obligations</li>
            </ul>
          </section>

          {/* Section 4 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              4. Sharing of Information
            </h2>
            <p className="text-gray-700 leading-relaxed mb-3">
              We do not sell your personal information. We share information
              only in the following circumstances:
            </p>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                With your assigned coach, so they can deliver your coaching
                program
              </li>
              <li>
                With trusted service providers who process data on our behalf
                (such as payment processing via Stripe and Apple, push
                notifications via Firebase Cloud Messaging, and cloud hosting),
                who may not use it for their own purposes
              </li>
              <li>
                When required by law, such as to comply with a legal process, or
                to protect our rights, your safety, or the safety of others
              </li>
            </ul>
          </section>

          {/* Section 5 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              5. Data Retention and Deletion
            </h2>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                We retain your data for as long as your account is active and
                for a reasonable period thereafter
              </li>
              <li>
                You may request deletion of your account and personal data at
                any time by contacting us at the email address below; we will
                respond within a reasonable time
              </li>
            </ul>
          </section>

          {/* Section 6 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              6. Your Rights
            </h2>
            <p className="text-gray-700 leading-relaxed mb-3">
              Under the General Data Protection Regulation (GDPR), you have the
              right to:
            </p>
            <ul className="list-disc pl-6 space-y-2 text-gray-700">
              <li>Access the personal data we hold about you</li>
              <li>Request correction of inaccurate data</li>
              <li>Request deletion of your data</li>
              <li>Object to or restrict certain processing</li>
              <li>Receive a copy of your data in a portable format</li>
              <li>
                Lodge a complaint with the Data Protection Commission (Ireland)
              </li>
            </ul>
            <p className="text-gray-700 leading-relaxed mt-3">
              To exercise any of these rights, contact us using the details
              below.
            </p>
          </section>

          {/* Section 7 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              7. Security
            </h2>
            <p className="text-gray-700 leading-relaxed">
              We implement physical, electronic, and procedural safeguards to
              protect the information we process and maintain. However, no
              method of transmission or storage is completely secure, and we
              cannot guarantee absolute security.
            </p>
          </section>

          {/* Section 8 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              8. Children's Privacy
            </h2>
            <p className="text-gray-700 leading-relaxed">
              The Service is intended for adults and is not directed at children
              under 18. We do not knowingly collect personal information from
              children. If you believe a child has provided us with personal
              information, please contact us so we can take appropriate action.
            </p>
          </section>

          {/* Section 9 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              9. Changes to This Policy
            </h2>
            <p className="text-gray-700 leading-relaxed">
              We may update this Privacy Policy from time to time. Changes will
              be posted on this page with an updated "Last Updated" date. You
              are advised to review this page periodically; continued use of the
              Service after changes constitutes acceptance of the updated
              policy.
            </p>
          </section>

          {/* Section 10 */}
          <section className="mb-8">
            <h2 className="text-2xl font-bold text-[#002C3F] mb-3">
              10. Contact Us
            </h2>
            <p className="text-gray-700 leading-relaxed mb-3">
              If you have any questions about this Privacy Policy or our data
              practices, please contact us at:
            </p>
            <div className="bg-gray-50 p-4 rounded-lg">
              <p className="font-semibold text-[#002C3F] mb-1">
                Midlands Performance Club
              </p>
              <p className="text-gray-700">
                Email:{' '}
                <a
                  href="mailto:shanemahon113@gmail.com"
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
        </div>
      </div>
    </div>
  );
};

export default PrivacyPolicyPage;

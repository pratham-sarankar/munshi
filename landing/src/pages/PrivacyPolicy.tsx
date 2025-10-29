import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";
import { Link } from "react-router-dom";

export function PrivacyPolicy() {
  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-border px-6 py-4 shadow-sm">
        <div className="mx-auto max-w-4xl flex items-center gap-4">
          <Link to="/">
            <Button variant="ghost" size="icon">
              <ArrowLeft className="h-5 w-5" />
            </Button>
          </Link>
          <h1 className="text-xl font-medium text-foreground">Privacy Policy</h1>
        </div>
      </header>

      {/* Content */}
      <main className="px-6 py-12 md:py-16">
        <article className="mx-auto max-w-4xl space-y-8">
          <div className="space-y-4">
            <h1 className="text-4xl md:text-5xl font-medium text-foreground">
              Privacy Policy
            </h1>
            <p className="text-lg text-secondary">
              Last updated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
            </p>
          </div>

          <div className="prose prose-gray max-w-none space-y-12">
            <section className="space-y-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Introduction
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Munshi ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our personal finance tracking application.
              </p>
              <p className="text-base text-secondary leading-relaxed">
                By using Munshi, you agree to the collection and use of information in accordance with this policy.
              </p>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Data Collection and Storage
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Munshi is designed with privacy as a core principle. All your financial data is stored locally on your device. We do not collect, transmit, or store any of your personal financial information on our servers.
              </p>
              <div className="bg-[#5856D6]/5 border border-[#5856D6]/20 rounded-xl p-6">
                <h3 className="text-lg font-medium text-foreground mb-3">
                  What data stays on your device:
                </h3>
                <ul className="space-y-2 text-secondary">
                  <li className="flex gap-2">
                    <span className="text-[#5856D6] mt-1">•</span>
                    <span>All transaction records and financial data</span>
                  </li>
                  <li className="flex gap-2">
                    <span className="text-[#5856D6] mt-1">•</span>
                    <span>Categories and tags you create</span>
                  </li>
                  <li className="flex gap-2">
                    <span className="text-[#5856D6] mt-1">•</span>
                    <span>Budget settings and preferences</span>
                  </li>
                  <li className="flex gap-2">
                    <span className="text-[#5856D6] mt-1">•</span>
                    <span>Charts, reports, and analytics data</span>
                  </li>
                </ul>
              </div>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Information We Collect
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Since Munshi operates entirely on your device, we collect minimal information:
              </p>
              <div className="space-y-4">
                <div>
                  <h3 className="text-lg font-medium text-foreground mb-2">
                    Anonymous Usage Analytics (Optional)
                  </h3>
                  <p className="text-base text-secondary leading-relaxed">
                    With your explicit consent, we may collect anonymized usage statistics to help improve the app, such as:
                  </p>
                  <ul className="mt-2 space-y-2 text-secondary ml-4">
                    <li>• App crash reports</li>
                    <li>• Feature usage patterns (which features are used most)</li>
                    <li>• Device type and operating system version</li>
                    <li>• App version information</li>
                  </ul>
                  <p className="text-base text-secondary leading-relaxed mt-2">
                    This data is completely anonymous and cannot be linked to you or your financial information.
                  </p>
                </div>
              </div>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                How We Use Your Information
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                The limited information we may collect is used solely to:
              </p>
              <ul className="space-y-2 text-secondary ml-4">
                <li>• Improve app performance and fix bugs</li>
                <li>• Understand which features are most valuable to users</li>
                <li>• Plan future feature development</li>
                <li>• Ensure compatibility across different devices</li>
              </ul>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Data Security
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Your financial data is stored securely on your device using industry-standard encryption. We recommend:
              </p>
              <ul className="space-y-2 text-secondary ml-4">
                <li>• Setting up device-level security (PIN, password, or biometric authentication)</li>
                <li>• Keeping your operating system and the app up to date</li>
                <li>• Regularly backing up your device data</li>
              </ul>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Third-Party Services
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Munshi may integrate with third-party services for optional features. These integrations are clearly disclosed and require your explicit consent. We do not share your financial data with any third parties.
              </p>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Your Rights
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Because all your data is stored locally on your device, you have complete control over it:
              </p>
              <ul className="space-y-2 text-secondary ml-4">
                <li>• <strong className="text-foreground">Access:</strong> You can view all your data within the app at any time</li>
                <li>• <strong className="text-foreground">Export:</strong> You can export your data in standard formats</li>
                <li>• <strong className="text-foreground">Delete:</strong> You can delete all data by uninstalling the app or clearing app data</li>
                <li>• <strong className="text-foreground">Control:</strong> You can disable analytics collection in the app settings</li>
              </ul>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Children's Privacy
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Munshi is not intended for use by children under the age of 13. We do not knowingly collect personal information from children under 13.
              </p>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Open Source
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                Munshi is open-source software. You can review our source code on{" "}
                <a 
                  href="https://github.com/pratham-sarankar/munshi" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-[#5856D6] hover:underline"
                >
                  GitHub
                </a>
                {" "}to verify our privacy practices and see exactly how your data is handled.
              </p>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Changes to This Privacy Policy
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.
              </p>
              <p className="text-base text-secondary leading-relaxed">
                You are advised to review this Privacy Policy periodically for any changes.
              </p>
            </section>

            <section className="space-y-4 pt-4">
              <h2 className="text-2xl md:text-3xl font-medium text-foreground">
                Contact Us
              </h2>
              <p className="text-base text-secondary leading-relaxed">
                If you have any questions about this Privacy Policy, please contact us:
              </p>
              <ul className="space-y-2 text-secondary ml-4">
                <li>• Email: <a href="mailto:support@munshi.app" className="text-[#5856D6] hover:underline">support@munshi.app</a></li>
                <li>• GitHub Issues: <a href="https://github.com/pratham-sarankar/munshi/issues" target="_blank" rel="noopener noreferrer" className="text-[#5856D6] hover:underline">github.com/pratham-sarankar/munshi/issues</a></li>
              </ul>
            </section>

            <div className="mt-12 pt-8 border-t border-border">
              <Link to="/">
                <Button variant="outline" className="gap-2">
                  <ArrowLeft className="h-4 w-4" />
                  Back to Home
                </Button>
              </Link>
            </div>
          </div>
        </article>
      </main>
    </div>
  );
}

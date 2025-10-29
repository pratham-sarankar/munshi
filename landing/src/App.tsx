import { Header } from "./components/Header";
import { Hero } from "./components/Hero";
import { Features } from "./components/Features";
import { HowItWorks } from "./components/HowItWorks";
import { Screenshots } from "./components/Screenshots";
import { Testimonials } from "./components/Testimonials";
import { FAQ } from "./components/FAQ";
import { CTA } from "./components/CTA";
import { Footer } from "./components/Footer";
import { Toaster } from "./components/ui/sonner";
import { Helmet } from "react-helmet";

export default function App() {
  return (
    <>
      <Helmet>
        <title>Munshi — Personal Finance Tracker</title>
        <meta 
          name="description" 
          content="Track your spending, save more, and stress less with Munshi. A lightweight personal finance app with beautiful animations, fast search, and easy categorization. Built with Flutter for Android and iOS." 
        />
        <meta name="keywords" content="expense tracker, personal finance, budgeting app, multi-currency, Flutter app, open source" />
        
        {/* Open Graph */}
        <meta property="og:title" content="Munshi — Personal Finance Tracker" />
        <meta property="og:description" content="Track your spending, save more, and stress less. A lightweight personal finance app with multi-currency support." />
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://munshi.app" />
        <meta property="og:site_name" content="Munshi" />
        
        {/* Twitter Card */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Munshi — Personal Finance Tracker" />
        <meta name="twitter:description" content="Track your spending, save more, and stress less with Munshi." />
        
        {/* Theme Color */}
        <meta name="theme-color" content="#5856D6" />
      </Helmet>

      <div className="min-h-screen bg-background">
        <Header />
        <main>
          <Hero />
          <Features />
          <HowItWorks />
          <Screenshots />
          <Testimonials />
          <FAQ />
          <CTA />
        </main>
        <Footer />
        <Toaster />
      </div>

      {/* JSON-LD Schema */}
      <script type="application/ld+json">
        {JSON.stringify({
          "@context": "https://schema.org",
          "@type": "SoftwareApplication",
          "name": "Munshi",
          "applicationCategory": "FinanceApplication",
          "operatingSystem": "Android, iOS",
          "offers": {
            "@type": "Offer",
            "price": "0",
            "priceCurrency": "USD"
          },
          "aggregateRating": {
            "@type": "AggregateRating",
            "ratingValue": "5",
            "ratingCount": "3"
          },
          "description": "A lightweight personal finance app with beautiful animations, fast search, and easy categorization. Built with Flutter for both Android and iOS."
        })}
      </script>
    </>
  );
}

import './App.css'

function App() {
  return (
    <div className="app">
      <header className="header">
        <div className="container">
          <h1 className="logo">Munshi</h1>
          <nav className="nav">
            <a href="#features">Features</a>
            <a href="#about">About</a>
            <a href="#download">Download</a>
          </nav>
        </div>
      </header>

      <main>
        <section className="hero">
          <div className="container">
            <h2 className="hero-title">Your Personal Finance Tracker</h2>
            <p className="hero-subtitle">
              Track your expenses, manage your budget, and take control of your finances with Munshi
            </p>
            <div className="cta-buttons">
              <a href="#download" className="btn btn-primary">Get Started</a>
              <a href="#features" className="btn btn-secondary">Learn More</a>
            </div>
          </div>
        </section>

        <section id="features" className="features">
          <div className="container">
            <h2 className="section-title">Features</h2>
            <div className="features-grid">
              <div className="feature-card">
                <div className="feature-icon">📊</div>
                <h3>Expense Tracking</h3>
                <p>Easily track and categorize all your transactions in one place</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">📈</div>
                <h3>Spending Analytics</h3>
                <p>Visualize your spending patterns with beautiful charts and insights</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">🎯</div>
                <h3>Budget Management</h3>
                <p>Set budgets and get notified when you're approaching your limits</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">🔒</div>
                <h3>Secure & Private</h3>
                <p>Your financial data is encrypted and stored securely on your device</p>
              </div>
            </div>
          </div>
        </section>

        <section id="about" className="about">
          <div className="container">
            <h2 className="section-title">About Munshi</h2>
            <p className="about-text">
              Munshi is a modern, intuitive personal finance tracker designed to help you take control 
              of your financial life. Built with Flutter for a seamless experience across Android and iOS, 
              Munshi makes it easy to track expenses, analyze spending patterns, and achieve your financial goals.
            </p>
          </div>
        </section>

        <section id="download" className="download">
          <div className="container">
            <h2 className="section-title">Get Munshi</h2>
            <p className="download-text">Available on Android and iOS</p>
            <div className="download-buttons">
              <a href="#" className="btn btn-store">
                <span>Download on</span>
                <strong>Google Play</strong>
              </a>
              <a href="#" className="btn btn-store">
                <span>Download on</span>
                <strong>App Store</strong>
              </a>
            </div>
          </div>
        </section>
      </main>

      <footer className="footer">
        <div className="container">
          <p>&copy; 2024 Munshi. All rights reserved.</p>
        </div>
      </footer>
    </div>
  )
}

export default App

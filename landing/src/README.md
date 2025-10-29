# Munshi Landing Page

A modern, responsive landing page for Munshi — a personal finance and expense tracker app built with Flutter.

## Overview

This landing page showcases the Munshi app with:
- Clean Material Design 3 aesthetic
- Manrope font (matching the app)
- Brand colors: Primary (#00695C teal) and Accent (#FFB300 amber)
- SEO optimized with meta tags and JSON-LD schema
- Fully responsive design (mobile-first)
- Accessibility focused (WCAG AA)

## Tech Stack

- **Framework**: React with TypeScript
- **Styling**: Tailwind CSS v4
- **Components**: shadcn/ui
- **Icons**: lucide-react
- **Font**: Manrope (Google Fonts)

## Project Structure

```
/
├── App.tsx                 # Main application with SEO meta tags
├── components/
│   ├── Header.tsx         # Navigation with GitHub link
│   ├── Hero.tsx           # Hero section with CTAs
│   ├── Features.tsx       # Key features showcase
│   ├── HowItWorks.tsx     # 3-step workflow
│   ├── Screenshots.tsx    # App screenshots carousel
│   ├── Testimonials.tsx   # User testimonials
│   ├── FAQ.tsx            # Frequently asked questions
│   ├── CTA.tsx            # Call-to-action section
│   └── Footer.tsx         # Footer with links
├── styles/
│   └── globals.css        # Global styles with custom properties
└── README.md              # This file
```

## Features

### Sections

1. **Header**: Sticky navigation with logo, links, and GitHub button
2. **Hero**: Eye-catching headline with download CTAs and key stats
3. **Features**: 6 feature cards highlighting app capabilities
4. **How It Works**: 3-step workflow visualization
5. **Screenshots**: Showcase of app interfaces
6. **Testimonials**: User reviews with ratings
7. **FAQ**: Common questions and answers
8. **CTA**: Final call-to-action with download buttons
9. **Footer**: Links, social media, and legal information

### Key Highlights

- ✅ **Privacy-focused**: Emphasizes local-first data storage
- ✅ **Open Source**: Links to GitHub repository
- ✅ **Indian Market**: INR formatting and India-specific features
- ✅ **Mobile-first**: Designed for mobile app promotion
- ✅ **SEO Ready**: Meta tags, Open Graph, and Schema.org markup
- ✅ **Accessible**: Semantic HTML, ARIA labels, keyboard navigation

## Color Palette

```css
Primary:    #00695C (Teal 700)
Accent:     #FFB300 (Amber 500)
Background: #FAFAFB (Light gray)
Surface:    #FFFFFF (White)
Text:       #0F172A (Dark slate)
Secondary:  #6B7280 (Gray)
```

## Running Locally

This project is built with React and can be run in a development environment. The main entry point is `/App.tsx`.

### Known Development Warnings

**Jotai Multiple Instances Warning**: You may see a console warning about "Detected multiple Jotai instances." This is a harmless warning that occurs because some shadcn/ui components (like sidebar) include Jotai as a dependency, even though they're not actively used in the landing page. This does not affect functionality or production builds and can be safely ignored.

## Deployment Suggestions

### GitHub Pages
1. Build the project
2. Deploy to `gh-pages` branch
3. Enable GitHub Pages in repository settings

### Vercel
1. Import repository to Vercel
2. Configure build settings
3. Deploy automatically on push

## Links

- **GitHub Repository**: [github.com/pratham-sarankar/munshi](https://github.com/pratham-sarankar/munshi)
- **Google Play**: (Add link when available)
- **App Store**: (Add link when available)

## Content Guidelines

All copy follows these principles:
- **Friendly & Concise**: Short sentences, active voice
- **Benefit-led**: Focus on user value
- **Honest**: No buzzwords or exaggeration
- **Privacy-focused**: Emphasize local-first approach

## Accessibility Checklist

- ✅ Semantic HTML structure
- ✅ ARIA labels where needed
- ✅ Keyboard navigation support
- ✅ Color contrast ratios >4.5:1
- ✅ Alt text for all images
- ✅ Focus states visible
- ✅ Responsive font sizes

## Performance Optimization

- Lazy-loaded images with fallbacks
- Optimized image formats (WebP)
- Minimal JavaScript
- Critical CSS inlining
- Preconnect to external resources

## Contributing

This is the landing page for an open-source project. Contributions are welcome!

1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

MIT License - matching the Munshi app license

## Credits

- **App Development**: [Pratham Sarankar](https://github.com/pratham-sarankar)
- **Landing Page**: Built with React, Tailwind CSS, and shadcn/ui
- **Images**: Unsplash (properly attributed)

---

Built with ❤️ in India

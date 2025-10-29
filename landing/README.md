# Munshi Landing Page

This is the landing page for Munshi, a personal finance tracker application. The landing page is built with React and TypeScript using Vite as the build tool.

## Development

### Prerequisites

- Node.js 20.x or higher
- npm

### Setup

```bash
npm install
```

### Development Server

```bash
npm run dev
```

The development server will start at `http://localhost:5173`

### Build

```bash
npm run build
```

The built files will be in the `dist` folder.

### Preview Production Build

```bash
npm run preview
```

## Deployment

The landing page is automatically deployed to GitHub Pages via GitHub Actions when changes are pushed to the `main` branch under the `landing/` directory.

The live site is available at: [https://munshi.sarankar.com](https://munshi.sarankar.com)

## Technology Stack

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and development server
- **CSS** - Styling

## Project Structure

```
landing/
├── public/          # Static assets and CNAME file
├── src/             # Source code
│   ├── App.tsx      # Main application component
│   ├── App.css      # Application styles
│   ├── main.tsx     # Entry point
│   └── index.css    # Global styles
├── index.html       # HTML template
├── package.json     # Dependencies and scripts
├── tsconfig.json    # TypeScript configuration
└── vite.config.ts   # Vite configuration
```

# GitHub Pages Setup Instructions

This document provides instructions for completing the GitHub Pages setup for the Munshi landing page.

## What Has Been Done

1. ✅ Created a React + TypeScript landing page in the `landing/` folder
2. ✅ Set up Vite as the build tool for fast development and optimized production builds
3. ✅ Created GitHub Actions workflow (`.github/workflows/deploy-landing.yml`) to automate deployment
4. ✅ Added CNAME file for custom domain (`munshi.sarankar.com`)
5. ✅ Updated `.gitignore` to exclude node_modules and build artifacts
6. ✅ Successfully tested the build locally

## Repository Settings Required

After merging this PR, you'll need to configure GitHub Pages in your repository settings:

### Steps to Enable GitHub Pages

1. Go to your repository on GitHub: https://github.com/pratham-sarankar/munshi
2. Click on **Settings** (top navigation)
3. In the left sidebar, click on **Pages** (under "Code and automation")
4. Under **Build and deployment**:
   - **Source**: Select "GitHub Actions"
   - This allows the workflow to deploy automatically
5. Under **Custom domain** (if not already set):
   - Enter: `munshi.sarankar.com`
   - Click **Save**
   - GitHub will verify the domain (make sure DNS is configured)

### DNS Configuration for Custom Domain

Ensure your DNS records are configured correctly for `munshi.sarankar.com`:

#### Option 1: Using CNAME (Recommended for subdomains)
```
Type: CNAME
Name: munshi
Value: pratham-sarankar.github.io
TTL: 3600 (or default)
```

#### Option 2: Using A Records (for apex domain)
If you're using the apex domain (sarankar.com), you'll need A records pointing to GitHub's IPs:
```
Type: A
Name: @
Value: 185.199.108.153
       185.199.109.153
       185.199.110.153
       185.199.111.153
TTL: 3600
```

And a CNAME for the www subdomain:
```
Type: CNAME
Name: www
Value: pratham-sarankar.github.io
TTL: 3600
```

## Workflow Details

The GitHub Actions workflow (`.github/workflows/deploy-landing.yml`) will:

1. **Trigger on**:
   - Push to `main` branch when files in `landing/` folder are modified
   - Manual trigger via workflow_dispatch

2. **Build process**:
   - Checkout the code
   - Setup Node.js 20
   - Install dependencies with `npm ci`
   - Build the React app with `npm run build`
   - Upload the built files to GitHub Pages

3. **Deploy process**:
   - Deploy the built files to GitHub Pages
   - Make the site available at the configured URL

## Testing the Workflow

Once the PR is merged to main:

1. The workflow will run automatically (if there are changes in `landing/`)
2. You can also trigger it manually:
   - Go to **Actions** tab
   - Select **Deploy Landing Page to GitHub Pages**
   - Click **Run workflow**

3. Monitor the workflow run:
   - Check the **Actions** tab for the workflow run
   - Ensure both "build" and "deploy" jobs complete successfully

4. Verify the deployment:
   - Visit https://munshi.sarankar.com (after DNS propagation)
   - The landing page should be live

## Local Development

To work on the landing page locally:

```bash
cd landing
npm install
npm run dev
```

The development server will start at http://localhost:5173

To build locally:
```bash
npm run build
```

The built files will be in `landing/dist/`

## Troubleshooting

### Workflow Fails

- Check the Actions tab for error messages
- Ensure all secrets are configured if needed (none required for this setup)
- Verify the build succeeds locally with `npm run build`

### Custom Domain Not Working

- Verify DNS records are configured correctly
- Wait for DNS propagation (can take up to 24-48 hours)
- Check that CNAME file exists in the deployed site
- Ensure "Enforce HTTPS" is enabled in Pages settings (after domain verification)

### 404 Page Not Found

- Ensure GitHub Pages is enabled in repository settings
- Check that the workflow completed successfully
- Verify the deployment was to the correct branch/source

## Security Notes

- The workflow uses minimal permissions (contents: read, pages: write, id-token: write)
- No secrets are required for this deployment
- The CNAME file is included in the build to ensure custom domain persists

## Next Steps

1. Merge this PR to the `main` branch
2. Configure GitHub Pages in repository settings
3. Verify DNS configuration for custom domain
4. Monitor the first workflow run
5. Test the deployed site at https://munshi.sarankar.com

For more information, see:
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Configuring a custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)

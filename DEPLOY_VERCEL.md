# Deploying to Vercel

## Option 1: Using Vercel CLI (Recommended)

1. **Install Vercel CLI** (if not already installed):
   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel**:
   ```bash
   vercel login
   ```

3. **Deploy from your project directory**:
   ```bash
   vercel
   ```
   
   Follow the prompts:
   - Link to existing project? **No** (first time) or **Yes** (if updating)
   - Project name: `api-docs-demo` (or your preferred name)
   - Directory: `.` (current directory)
   - Override settings? **No**

4. **For production deployment**:
   ```bash
   vercel --prod
   ```

## Option 2: Using GitHub Integration (Easier)

1. **Go to [vercel.com](https://vercel.com)** and sign in with GitHub

2. **Click "Add New Project"**

3. **Import your repository**:
   - Select `Parthsingh2111/api-docs-demo` from the list
   - Click "Import"

4. **Configure the project**:
   - **Framework Preset**: Other
   - **Root Directory**: `.` (leave as default)
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Install Command**: (leave empty, Flutter handles this)

5. **Add Environment Variables** (if needed):
   - Click "Environment Variables"
   - Add any required variables

6. **Click "Deploy"**

## Build Configuration

The `vercel.json` file is already configured with:
- ✅ Build command: `flutter build web --release`
- ✅ Output directory: `build/web`
- ✅ SPA routing (all routes redirect to index.html)
- ✅ Security headers
- ✅ Asset caching

## Important Notes

- **Flutter SDK**: Vercel will need Flutter installed. You may need to add a build script or use a custom Docker image.
- **Alternative**: Consider using GitHub Actions to build Flutter web, then deploy the `build/web` folder to Vercel.

## Troubleshooting

If Flutter is not available on Vercel's build environment, you can:

1. **Use GitHub Actions** to build Flutter web
2. **Deploy the built files** to Vercel

Or use a **custom build script** that installs Flutter first.


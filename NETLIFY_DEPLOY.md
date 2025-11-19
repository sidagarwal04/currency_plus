# Deploy to Netlify - Simple Method

## 🚀 Quick Deploy (Drag & Drop - Easiest!)

### Step 1: Go to Netlify Drop
Open: **https://app.netlify.com/drop**

### Step 2: Drag Your Build Folder
Drag and drop this folder:
```
/Users/sidagarwal/Documents/GitHub/currency_plus/build/web
```

### Step 3: Done! 🎉
Your app will be live in seconds with a URL like:
```
https://random-name-123456.netlify.app
```

## 🔗 Connect to GitHub (Automatic Deploys)

### Step 1: Login to Netlify
Go to: https://app.netlify.com/

### Step 2: Import from GitHub
1. Click **"Add new site"** → **"Import an existing project"**
2. Choose **"Deploy with GitHub"**
3. Authorize Netlify to access your GitHub
4. Select repository: **`sidagarwal04/currency_plus`**

### Step 3: Configure Build Settings
```
Build command: flutter build web
Publish directory: build/web
```

### Step 4: Add Environment Variables (Optional)
If you want to use environment variables for API key:
- Go to Site settings → Environment variables
- Add: `API_KEY` = `your_api_key_here`

### Step 5: Deploy!
Click **"Deploy site"**

**Automatic Updates:**
- Every push to `main` branch auto-deploys
- Pull request previews available
- Instant rollback if needed

## 🎨 Customize Your Site

### Change Site Name
1. Go to Site settings
2. Change site name
3. Your URL becomes: `https://your-name.netlify.app`

### Add Custom Domain
1. Go to Domain settings
2. Add custom domain
3. Follow DNS instructions
4. Get free HTTPS automatically

## ⚡ Build Settings for GitHub Deploy

Create `netlify.toml` in project root:

```toml
[build]
  command = "flutter build web"
  publish = "build/web"

[build.environment]
  FLUTTER_VERSION = "3.38.0"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

## 🔧 Current Build Status

Your web build is ready at:
```
/Users/sidagarwal/Documents/GitHub/currency_plus/build/web
```

## 📝 Alternative: Manual Deploy via CLI

If you want to try CLI again later:

```bash
# Login
netlify login

# Deploy
cd build/web
netlify deploy --prod --dir .
```

## ✅ What's Included

Your deployment includes:
- ✅ Optimized Flutter web build
- ✅ Tree-shaken icons (99.5% smaller)
- ✅ PWA manifest
- ✅ Favicon and icons
- ✅ Responsive design
- ✅ Dark mode support

## 🌐 After Deployment

1. **Test Your Site** - Check all features work
2. **Update README** - Add live demo link
3. **Share** - Your app is now live!

## 📱 PWA Installation

Users can install your app:
1. Visit your Netlify URL
2. Browser prompts: "Add to Home Screen"
3. Works like a native app!

---

**Recommended:** Use the **Drag & Drop** method for quickest deployment!

Go to: https://app.netlify.com/drop and drag the `build/web` folder.

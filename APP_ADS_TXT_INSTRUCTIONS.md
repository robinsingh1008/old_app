# How to Fix AdMob app-ads.txt Verification Issue

## Problem
AdMob cannot verify your app because the `app-ads.txt` file is missing at `oldbooks.com/app-ads.txt`.

## Solution Steps

### Step 1: Upload app-ads.txt File to Your Website

1. **Access your website hosting** (oldbooks.com)
   - Log in to your web hosting control panel (cPanel, FTP, or hosting dashboard)
   - Navigate to the root directory of your domain (usually `public_html` or `www`)

2. **Upload the app-ads.txt file**
   - The file `app-ads.txt` has been created in your project folder
   - Upload it to the root of your domain: `oldbooks.com/app-ads.txt`
   - Make sure the file is accessible via both:
     - `http://oldbooks.com/app-ads.txt`
     - `https://oldbooks.com/app-ads.txt` (if you have SSL)

### Step 2: Fix SSL Certificate Issue (if using HTTPS)

If you're using HTTPS, ensure:
- Your SSL certificate is valid and not expired
- The certificate is properly installed
- The domain uses HTTPS correctly

### Step 3: Verify File is Accessible

Test that the file is accessible:
- Open browser and go to: `https://oldbooks.com/app-ads.txt`
- Or: `http://oldbooks.com/app-ads.txt`
- You should see the content of the file

### Step 4: Wait for AdMob to Crawl

1. Go to your AdMob account
2. Navigate to **App settings** → **App-ads.txt**
3. Click **"Request verification"** or wait (AdMob crawls every 24 hours)
4. It may take up to 24-48 hours for verification

### Step 5: Alternative - Update Google Play Listing

If you don't have a website:
1. Go to Google Play Console
2. Select your app: "UP TGT PGT LT Math 6 Old Books"
3. Go to **Store presence** → **Store settings**
4. Update the **Developer website** to a valid domain you control
5. Upload the `app-ads.txt` file to that domain

## File Content

The `app-ads.txt` file contains:
```
google.com, pub-9189593829339774, DIRECT, f08c47fec0942fa0
```

This authorizes Google AdMob to serve ads for your publisher ID: `ca-app-pub-9189593829339774`

## Important Notes

- The file must be at the root: `oldbooks.com/app-ads.txt` (not in a subdirectory)
- File must be accessible via HTTP or HTTPS
- File must be in plain text format (not HTML)
- No redirects should be used
- File should be publicly accessible (no authentication required)

## Verification

After uploading, verify:
1. File is accessible in browser
2. File returns HTTP 200 status (not 404)
3. SSL certificate is valid (if using HTTPS)
4. File content is correct (matches your publisher ID)

## Troubleshooting

- **404 Error**: File not found → Upload file to correct location
- **SSL Error**: Certificate issue → Fix SSL certificate or use HTTP
- **Still not verified**: Wait 24-48 hours for AdMob to re-crawl


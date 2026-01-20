# App-Ads.txt Setup Instructions

## समस्या
Google Play को आपके app को verify नहीं कर पा रहा क्योंकि `app-ads.txt` file नहीं मिल रही।

## समाधान

### Step 1: robots.txt File बनाएं
Website की root directory में एक `robots.txt` file create करें जो app-ads.txt को allow करे:

```
User-agent: *
Allow: /app-ads.txt
Disallow: /
```

### Step 2: app-ads.txt File Upload करें
यह file आपकी website की root directory पर होनी चाहिए:

**URL:** `https://oldbooks.com/app-ads.txt`

**File Location:** `/public_html/app-ads.txt` (या hosting provider के अनुसार)

**Content:**
```
google.com, pub-9189593829339774, DIRECT, f08c47fec0942fa0
```

### Step 3: Hosting पर Upload करने के तरीके

#### Option A: cPanel के through
1. cPanel खोलें → File Manager
2. `/public_html` folder में जाएं
3. दोनों files upload करें:
   - `robots.txt`
   - `app-ads.txt`

#### Option B: FTP के through
1. FTP client (FileZilla, WinSCP) खोलें
2. अपने hosting के FTP credentials से login करें
3. `/public_html` (या root) folder में navigate करें
4. दोनों files upload करें

#### Option C: SSH/Terminal के through
```bash
# अपने server पर connect करें
ssh username@oldbooks.com

# Website root directory में जाएं
cd /var/www/oldbooks.com/public_html/
# या
cd ~/public_html/

# app-ads.txt create करें
cat > app-ads.txt << 'EOF'
google.com, pub-9189593829339774, DIRECT, f08c47fec0942fa0
EOF

# robots.txt create करें
cat > robots.txt << 'EOF'
User-agent: *
Allow: /app-ads.txt
Disallow: /
EOF

# Permissions set करें
chmod 644 app-ads.txt robots.txt
```

### Step 4: Verify करें
1. Browser में खोलें: `https://oldbooks.com/app-ads.txt`
2. File content दिखना चाहिए

### Step 5: Google Play पर Re-submit करें
1. Google Play Console खोलें
2. आपकी app की setup जाएं
3. App ads verification फिर से करें
4. कुछ hours में verify हो जाएगा

---

## Files की Location (Project में)
- Root level app-ads.txt: `/Users/mac/Desktop/Flutterproject/old_book/app-ads.txt`
- Alternate copy: `/Users/mac/Desktop/Flutterproject/old_book/oldbooks-app-ads/app-ads.txt`

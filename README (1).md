# 🏢 Condo Market SF

**San Francisco's Premier Condo Marketplace - Complete Real Estate Platform**

A professional real estate platform specializing in luxury San Francisco condominiums, built with modern web technologies and designed for maximum performance and user experience.

---

## 🚀 **Platform Overview**

Condo Market SF is a complete real estate marketplace modeled after specialized property platforms, featuring:

- **64 Premium Buildings** with comprehensive analytics
- **Professional LOI System** with agent review workflow
- **Make Me Move** private seller platform
- **Advanced Search & Filters** with building comparisons
- **User Dashboard** with offers, saved buildings, and listings management
- **Market Intelligence** with trends and analytics
- **Mobile-First Design** with responsive interfaces

---

## 🛠️ **Tech Stack**

### **Frontend**
- **HTML5/CSS3/JavaScript** - Modern responsive design
- **Google Fonts** - Playfair Display + DM Sans typography
- **Chart.js** - Data visualizations and market charts
- **Responsive Design** - Mobile-first approach

### **Backend & Database**
- **Supabase** - PostgreSQL database with real-time features
- **Row Level Security (RLS)** - Secure data access
- **Authentication** - Built-in user management
- **API** - RESTful endpoints with real-time subscriptions

### **Infrastructure**
- **Cloudflare Pages** - Static hosting with global CDN
- **GitHub** - Version control and CI/CD pipeline
- **Resend** - Transactional email service
- **Custom Domain** - Professional branding

---

## 📁 **Project Structure**

```
condo-market-sf/
├── index.html                 # Homepage
├── buildings.html             # Building directory/search
├── building-detail.html       # Individual building pages
├── submit-offer.html          # LOI submission workflow
├── dashboard.html             # User management dashboard
├── make-me-move.html          # Property owner tools
├── js/
│   └── supabase-config.js     # Backend integration
├── images/                    # Building photos & assets
│   ├── lumina.jpg
│   ├── one-rincon-hill.jpg
│   └── ...
├── database/
│   └── schema.sql             # Complete database schema
├── package.json               # Dependencies & scripts
├── wrangler.toml              # Cloudflare configuration
└── README.md                  # This file
```

---

## ⚡ **Features**

### **🏗️ Building Analytics**
- Comprehensive building data (64 buildings)
- Unit availability and pricing
- HOA financials and fee structures
- Market trends and price history
- Building amenities and features
- Recent sales comparables

### **📝 Letter of Intent (LOI) Workflow**
1. **Buyer writes offer** - Complete form with terms
2. **LOI produced & delivered to Tim** - Professional generation
3. **Call with Tim** - Strategy and guidance
4. **LOI delivered to homeowner** - Professional presentation

### **🎯 Make Me Move Platform**
- Private premium pricing
- Serious buyer qualification
- No traditional listing hassles
- Professional presentation
- Direct owner communication

### **👤 User Management**
- Secure authentication
- Personal dashboard
- Offer tracking and management
- Saved buildings with alerts
- Listing management tools

### **🔍 Advanced Search**
- Filter by neighborhood, price, amenities
- Building comparison tools
- Map-based discovery
- Saved searches and alerts
- Professional insights

---

## 🚀 **Deployment Instructions**

### **1. Clone Repository**
```bash
git clone https://github.com/your-username/condo-market-sf.git
cd condo-market-sf
npm install
```

### **2. Setup Supabase Database**

1. Create new Supabase project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key
3. Run the database schema:
   ```sql
   -- In Supabase SQL editor, paste and run:
   -- Contents of database/schema.sql
   ```

### **3. Configure Environment Variables**

Update `/js/supabase-config.js`:
```javascript
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
```

### **4. Setup Cloudflare Pages**

1. **Create Cloudflare Account** at [cloudflare.com](https://cloudflare.com)
2. **Connect GitHub Repository**:
   - Pages → Create a project
   - Connect to Git → Select repository
3. **Configure Build Settings**:
   - Build command: (empty)
   - Build output directory: `/`
   - Root directory: `/`

### **5. Setup Custom Domain**

1. **Add Domain** in Cloudflare Pages
2. **Configure DNS** records
3. **Enable SSL/TLS** (automatic)

### **6. Configure Email Service**

1. **Create Resend Account** at [resend.com](https://resend.com)
2. **Get API Key** from dashboard
3. **Add Environment Variables** in Cloudflare:
   - `RESEND_API_KEY`
   - `TIM_EMAIL`

### **7. Deploy**

```bash
# Using Wrangler CLI
npm install -g wrangler
wrangler pages publish . --project-name=condo-market-sf

# Or push to GitHub (automatic deployment)
git add .
git commit -m "Initial deployment"
git push origin main
```

---

## 📊 **Database Schema**

The platform uses a comprehensive PostgreSQL schema with:

- **Buildings** - Property data and analytics
- **Units** - Individual condo information
- **Offers** - LOI submission and tracking
- **MMM Listings** - Make Me Move properties
- **Users** - Authentication and profiles
- **Sales** - Market data and comparables
- **Analytics** - Performance metrics

All tables include Row Level Security (RLS) policies for secure data access.

---

## 🎨 **Design System**

### **Brand Colors**
- **Primary**: #9fb4d8 (Blue-gray)
- **Secondary**: #1a1f2e (Navy)
- **Accent**: #7a99cc (Light blue)
- **Text**: #333333 (Charcoal)
- **Background**: #fafbfc (Off-white)

### **Typography**
- **Headings**: Playfair Display (serif)
- **Body Text**: DM Sans (sans-serif)
- **UI Elements**: DM Sans (various weights)

### **Components**
- Consistent button styles and interactions
- Card-based layouts for content
- Modal dialogs for forms
- Responsive grid systems
- Professional color schemes

---

## 🔧 **Development**

### **Local Development**
```bash
# Install dependencies
npm install

# Run local server
npm run dev

# Open browser to http://localhost:3000
```

### **Build Process**
```bash
# Optimize for production
npm run build

# Test production build
npm run preview
```

### **Key Files to Customize**
- **Building Data**: Update building information in database
- **Images**: Add building photos to `/images/` directory
- **Contact Info**: Update Tim's contact details throughout
- **Branding**: Modify colors and logos in CSS

---

## 📧 **Email Integration**

The platform uses Resend for transactional emails:

- **LOI Notifications** - Alerts to Tim when offers submitted
- **User Registration** - Welcome emails for new accounts
- **Offer Updates** - Status changes and responses
- **Market Alerts** - Price changes and new listings

Email templates are configured in the Supabase backend.

---

## 🔒 **Security Features**

- **Authentication** - Secure user registration and login
- **Row Level Security** - Database access controls
- **HTTPS Everywhere** - SSL/TLS encryption
- **Input Validation** - Form security and sanitization
- **Rate Limiting** - API protection
- **Privacy Controls** - User data protection

---

## 📱 **Mobile Optimization**

- **Responsive Design** - Works on all screen sizes
- **Touch-Friendly** - Optimized for mobile interactions
- **Fast Loading** - Optimized images and code
- **Progressive Enhancement** - Core functionality always available

---

## 🚀 **Performance**

- **Cloudflare CDN** - Global content delivery
- **Image Optimization** - Compressed and optimized
- **Code Splitting** - Efficient resource loading
- **Caching Strategy** - Smart browser and CDN caching
- **Core Web Vitals** - Optimized user experience metrics

---

## 📈 **Analytics & Monitoring**

Track platform performance with:
- User registration and engagement
- Offer submission rates
- Building page views
- Search patterns and filters
- Market data usage

---

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 **License**

This project is licensed under the MIT License. See `LICENSE` file for details.

---

## 📞 **Support**

For technical support or questions:

- **Email**: tim@mcmullen.properties
- **Phone**: (415) 691-9272
- **Website**: [your-domain.com](https://your-domain.com)

---

## 🏗️ **Built By**

**Tim McMullen** - *Founder & Principal*  
McMullen Properties  
DRE #02016832  
Campbell, CA

*Specialized in San Francisco luxury condominiums with over a decade of market expertise and professional guidance.*

---

**© 2026 Condo Market SF. All rights reserved.**
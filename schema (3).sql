-- Condo Market Database Schema
-- Run this in your Supabase SQL editor to create all necessary tables

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Buildings table
CREATE TABLE buildings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  address TEXT NOT NULL,
  neighborhood TEXT NOT NULL,
  year_built INTEGER,
  total_units INTEGER,
  floors INTEGER,
  price_min DECIMAL,
  price_max DECIMAL,
  avg_price_per_sqft DECIMAL,
  description TEXT,
  architect TEXT,
  developer TEXT,
  building_type TEXT DEFAULT 'high-rise',
  pet_policy TEXT,
  parking_available BOOLEAN DEFAULT true,
  images JSONB DEFAULT '[]',
  location_lat DECIMAL(10, 8),
  location_lng DECIMAL(11, 8),
  website_url TEXT,
  hoa_contact TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Building amenities
CREATE TABLE building_amenities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  building_id UUID REFERENCES buildings(id) ON DELETE CASCADE,
  amenity_type TEXT NOT NULL, -- 'pool', 'gym', 'concierge', 'rooftop', 'valet', etc.
  amenity_name TEXT NOT NULL,
  description TEXT,
  hours TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Units table
CREATE TABLE units (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  building_id UUID REFERENCES buildings(id) ON DELETE CASCADE,
  unit_number TEXT NOT NULL,
  floor INTEGER,
  bedrooms DECIMAL(2,1), -- Allows for 1.5 bedrooms
  bathrooms DECIMAL(2,1),
  square_footage INTEGER,
  price_current DECIMAL,
  price_original DECIMAL,
  status TEXT DEFAULT 'available', -- 'available', 'pending', 'sold', 'make_me_move'
  listing_date DATE,
  view_type TEXT, -- 'bay', 'city', 'bay_city', 'partial', 'interior'
  parking_spaces INTEGER DEFAULT 0,
  storage_included BOOLEAN DEFAULT false,
  hoa_fee_monthly DECIMAL,
  property_taxes_annual DECIMAL,
  images JSONB DEFAULT '[]',
  floor_plan_url TEXT,
  mls_number TEXT,
  agent_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unit features
CREATE TABLE unit_features (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  unit_id UUID REFERENCES units(id) ON DELETE CASCADE,
  feature_type TEXT NOT NULL, -- 'flooring', 'appliance', 'upgrade', 'view_feature'
  feature_name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Offers table
CREATE TABLE offers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  unit_id UUID REFERENCES units(id) ON DELETE CASCADE,
  building_id UUID REFERENCES buildings(id) ON DELETE CASCADE,
  offer_price DECIMAL NOT NULL,
  earnest_money DECIMAL,
  earnest_money_percentage DECIMAL,
  financing_type TEXT, -- 'cash', 'conventional', 'jumbo'
  down_payment_percentage DECIMAL,
  pre_approval_status TEXT, -- 'pre-approved', 'pre-qualified', 'working'
  lender_name TEXT,
  loan_officer_contact TEXT,
  closing_date DATE,
  offer_expiration_hours INTEGER DEFAULT 48,
  contingencies JSONB DEFAULT '[]', -- Array of contingencies
  special_terms TEXT,
  status TEXT DEFAULT 'submitted', -- 'submitted', 'under_review', 'countered', 'accepted', 'declined', 'expired'
  loi_generated BOOLEAN DEFAULT false,
  loi_reviewed_by_agent BOOLEAN DEFAULT false,
  agent_call_completed BOOLEAN DEFAULT false,
  loi_sent_to_owner BOOLEAN DEFAULT false,
  counter_offer_price DECIMAL,
  counter_offer_terms TEXT,
  decline_reason TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Make Me Move listings
CREATE TABLE mmm_listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  property_address TEXT NOT NULL,
  building_id UUID REFERENCES buildings(id),
  unit_number TEXT,
  mmm_price DECIMAL NOT NULL,
  min_offer DECIMAL,
  bedrooms DECIMAL(2,1),
  bathrooms DECIMAL(2,1),
  square_footage INTEGER,
  floor INTEGER,
  view_type TEXT,
  parking_spaces INTEGER DEFAULT 0,
  features JSONB DEFAULT '[]',
  upgrades JSONB DEFAULT '[]',
  purchase_price DECIMAL,
  purchase_date DATE,
  timeline TEXT DEFAULT 'flexible', -- 'flexible', 'moderate', 'urgent'
  display_preference TEXT DEFAULT 'show_price', -- 'show_price', 'show_range', 'private'
  contact_preference TEXT DEFAULT 'agent', -- 'agent', 'direct', 'email'
  owner_name TEXT,
  selling_reason TEXT,
  special_notes TEXT,
  photo_preference TEXT DEFAULT 'existing', -- 'existing', 'custom', 'professional'
  status TEXT DEFAULT 'active', -- 'active', 'paused', 'sold', 'withdrawn'
  views_count INTEGER DEFAULT 0,
  inquiries_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Make Me Move offers
CREATE TABLE mmm_offers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  mmm_listing_id UUID REFERENCES mmm_listings(id) ON DELETE CASCADE,
  buyer_user_id UUID REFERENCES auth.users(id),
  offer_price DECIMAL NOT NULL,
  buyer_name TEXT,
  buyer_email TEXT,
  buyer_phone TEXT,
  financing_type TEXT,
  pre_approval_status TEXT,
  message TEXT,
  status TEXT DEFAULT 'submitted', -- 'submitted', 'viewed', 'interested', 'declined'
  owner_response TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Saved buildings (user favorites)
CREATE TABLE saved_buildings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  building_id UUID REFERENCES buildings(id) ON DELETE CASCADE,
  price_alert_enabled BOOLEAN DEFAULT false,
  price_alert_min DECIMAL,
  price_alert_max DECIMAL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, building_id)
);

-- Sales history
CREATE TABLE sales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  unit_id UUID REFERENCES units(id) ON DELETE CASCADE,
  building_id UUID REFERENCES buildings(id) ON DELETE CASCADE,
  sale_price DECIMAL NOT NULL,
  price_per_sqft DECIMAL,
  sale_date DATE NOT NULL,
  days_on_market INTEGER,
  bedrooms DECIMAL(2,1),
  bathrooms DECIMAL(2,1),
  square_footage INTEGER,
  floor INTEGER,
  view_type TEXT,
  sale_type TEXT DEFAULT 'mls', -- 'mls', 'off_market', 'make_me_move'
  buyer_agent TEXT,
  seller_agent TEXT,
  commission_rate DECIMAL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Building analytics (computed metrics)
CREATE TABLE building_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  building_id UUID REFERENCES buildings(id) ON DELETE CASCADE,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  avg_price_per_sqft DECIMAL,
  median_sale_price DECIMAL,
  total_sales INTEGER DEFAULT 0,
  avg_days_on_market DECIMAL,
  price_trend_percentage DECIMAL,
  active_listings INTEGER DEFAULT 0,
  pending_sales INTEGER DEFAULT 0,
  mmm_listings INTEGER DEFAULT 0,
  avg_mmm_price DECIMAL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(building_id, period_start, period_end)
);

-- Market trends (neighborhood level)
CREATE TABLE market_trends (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  neighborhood TEXT NOT NULL,
  date DATE NOT NULL,
  avg_price_per_sqft DECIMAL,
  median_price DECIMAL,
  total_sales INTEGER DEFAULT 0,
  avg_days_on_market DECIMAL,
  inventory_count INTEGER DEFAULT 0,
  price_change_mom DECIMAL, -- Month over month
  price_change_yoy DECIMAL, -- Year over year
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(neighborhood, date)
);

-- User profiles (extends auth.users)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT,
  bio TEXT,
  avatar_url TEXT,
  is_agent BOOLEAN DEFAULT false,
  agent_license TEXT,
  brokerage TEXT,
  specialties TEXT[],
  notification_preferences JSONB DEFAULT '{"email": true, "sms": false}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Email notifications queue
CREATE TABLE email_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_email TEXT NOT NULL,
  recipient_name TEXT,
  template_name TEXT NOT NULL,
  template_data JSONB DEFAULT '{}',
  status TEXT DEFAULT 'pending', -- 'pending', 'sent', 'failed'
  error_message TEXT,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS (Row Level Security) Policies

-- Enable RLS on all tables
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE mmm_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE mmm_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_buildings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_queue ENABLE ROW LEVEL SECURITY;

-- Offers policies
CREATE POLICY "Users can view their own offers" ON offers
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own offers" ON offers
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own offers" ON offers
  FOR UPDATE USING (auth.uid() = user_id);

-- MMM Listings policies
CREATE POLICY "Users can view their own MMM listings" ON mmm_listings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own MMM listings" ON mmm_listings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own MMM listings" ON mmm_listings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view active MMM listings" ON mmm_listings
  FOR SELECT USING (status = 'active');

-- MMM Offers policies
CREATE POLICY "Users can view offers on their listings" ON mmm_offers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM mmm_listings 
      WHERE id = mmm_offers.mmm_listing_id 
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view their own MMM offers" ON mmm_offers
  FOR SELECT USING (auth.uid() = buyer_user_id);

CREATE POLICY "Anyone can insert MMM offers" ON mmm_offers
  FOR INSERT WITH CHECK (true);

-- Saved buildings policies
CREATE POLICY "Users can manage their own saved buildings" ON saved_buildings
  FOR ALL USING (auth.uid() = user_id);

-- User profiles policies
CREATE POLICY "Users can view their own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Public read access for buildings, units, sales, analytics
CREATE POLICY "Anyone can view buildings" ON buildings FOR SELECT USING (true);
CREATE POLICY "Anyone can view building amenities" ON building_amenities FOR SELECT USING (true);
CREATE POLICY "Anyone can view units" ON units FOR SELECT USING (true);
CREATE POLICY "Anyone can view unit features" ON unit_features FOR SELECT USING (true);
CREATE POLICY "Anyone can view sales" ON sales FOR SELECT USING (true);
CREATE POLICY "Anyone can view building analytics" ON building_analytics FOR SELECT USING (true);
CREATE POLICY "Anyone can view market trends" ON market_trends FOR SELECT USING (true);

-- Indexes for performance
CREATE INDEX idx_buildings_neighborhood ON buildings(neighborhood);
CREATE INDEX idx_buildings_slug ON buildings(slug);
CREATE INDEX idx_units_building_status ON units(building_id, status);
CREATE INDEX idx_units_price_range ON units(price_current);
CREATE INDEX idx_offers_user_status ON offers(user_id, status);
CREATE INDEX idx_offers_created_at ON offers(created_at DESC);
CREATE INDEX idx_mmm_listings_status ON mmm_listings(status);
CREATE INDEX idx_mmm_listings_price ON mmm_listings(mmm_price);
CREATE INDEX idx_saved_buildings_user ON saved_buildings(user_id);
CREATE INDEX idx_sales_building_date ON sales(building_id, sale_date DESC);
CREATE INDEX idx_market_trends_neighborhood_date ON market_trends(neighborhood, date DESC);

-- Functions for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Triggers for auto-updating timestamps
CREATE TRIGGER update_buildings_updated_at BEFORE UPDATE ON buildings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_units_updated_at BEFORE UPDATE ON units
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_offers_updated_at BEFORE UPDATE ON offers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mmm_listings_updated_at BEFORE UPDATE ON mmm_listings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mmm_offers_updated_at BEFORE UPDATE ON mmm_offers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data for development (remove in production)
INSERT INTO buildings (name, slug, address, neighborhood, year_built, total_units, floors, price_min, price_max, avg_price_per_sqft) VALUES
('LUMINA', 'lumina', '201 Folsom St', 'South Beach', 2009, 664, 42, 850000, 4200000, 1264),
('One Rincon Hill', 'one-rincon-hill', '425 1st St', 'South Beach', 2008, 709, 64, 1200000, 5800000, 1485),
('Millennium Tower', 'millennium-tower', '301 Mission St', 'Yerba Buena', 2009, 407, 58, 950000, 3800000, 1033),
('1 Daniel Burnham', '1-daniel-burnham', '1 Daniel Burnham Ct', 'Civic Center', 2005, 247, 18, 425000, 1200000, 655);
// Condo Market - Supabase Configuration & Backend Integration
// This file handles all database operations and authentication

class CondoMarket {
  constructor() {
    this.supabase = null;
    this.currentUser = null;
    this.init();
  }

  // Initialize Supabase client
  init() {
    // These will be environment variables in production
    const supabaseUrl = 'YOUR_SUPABASE_URL';
    const supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
    
    this.supabase = supabase.createClient(supabaseUrl, supabaseKey);
    this.checkAuthState();
  }

  // Authentication Methods
  async checkAuthState() {
    const { data: { user } } = await this.supabase.auth.getUser();
    this.currentUser = user;
    return user;
  }

  async signUp(email, password, fullName) {
    const { data, error } = await this.supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName
        }
      }
    });
    
    if (error) throw error;
    this.currentUser = data.user;
    return data;
  }

  async signIn(email, password) {
    const { data, error } = await this.supabase.auth.signInWithPassword({
      email,
      password
    });
    
    if (error) throw error;
    this.currentUser = data.user;
    return data;
  }

  async signOut() {
    const { error } = await this.supabase.auth.signOut();
    if (error) throw error;
    this.currentUser = null;
    window.location.href = '/';
  }

  getCurrentUser() {
    return this.currentUser;
  }

  // Building Methods
  async getAllBuildings() {
    const { data, error } = await this.supabase
      .from('buildings')
      .select('*')
      .order('name');
    
    if (error) throw error;
    return data;
  }

  async getBuildingById(buildingId) {
    const { data, error } = await this.supabase
      .from('buildings')
      .select(`
        *,
        units(*),
        building_amenities(*),
        recent_sales(*)
      `)
      .eq('id', buildingId)
      .single();
    
    if (error) throw error;
    return data;
  }

  async searchBuildings(filters) {
    let query = this.supabase.from('buildings').select('*');
    
    if (filters.neighborhood) {
      query = query.in('neighborhood', filters.neighborhood);
    }
    
    if (filters.minPrice) {
      query = query.gte('price_min', filters.minPrice);
    }
    
    if (filters.maxPrice) {
      query = query.lte('price_max', filters.maxPrice);
    }
    
    if (filters.amenities) {
      // Join with building_amenities table
      query = query.eq('building_amenities.amenity_type', filters.amenities);
    }
    
    const { data, error } = await query.order('name');
    if (error) throw error;
    return data;
  }

  // Unit Methods
  async getAvailableUnits(buildingId) {
    const { data, error } = await this.supabase
      .from('units')
      .select('*')
      .eq('building_id', buildingId)
      .eq('status', 'available')
      .order('unit_number');
    
    if (error) throw error;
    return data;
  }

  async getUnitById(unitId) {
    const { data, error } = await this.supabase
      .from('units')
      .select(`
        *,
        buildings(*),
        unit_features(*)
      `)
      .eq('id', unitId)
      .single();
    
    if (error) throw error;
    return data;
  }

  // Offer Methods
  async submitOffer(offerData) {
    const userId = this.currentUser?.id;
    if (!userId) throw new Error('User must be authenticated to submit offers');

    const { data, error } = await this.supabase
      .from('offers')
      .insert({
        user_id: userId,
        unit_id: offerData.unitId,
        building_id: offerData.buildingId,
        offer_price: offerData.offerPrice,
        earnest_money: offerData.earnestMoney,
        financing_type: offerData.financingType,
        closing_date: offerData.closingDate,
        contingencies: offerData.contingencies,
        special_terms: offerData.specialTerms,
        status: 'submitted',
        loi_generated: true,
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;

    // Generate LOI and notify Tim
    await this.generateLOI(data.id, offerData);
    
    return data;
  }

  async generateLOI(offerId, offerData) {
    // Send LOI to Tim via Resend
    const emailData = {
      to: 'tim@mcmullen.properties',
      subject: `New LOI Generated - ${offerData.buildingName} Unit ${offerData.unitNumber}`,
      template: 'loi-notification',
      data: {
        offerId: offerId,
        offerPrice: offerData.offerPrice,
        buildingName: offerData.buildingName,
        unitNumber: offerData.unitNumber,
        buyerName: this.currentUser.user_metadata.full_name || this.currentUser.email
      }
    };

    // This would integrate with Resend API
    await this.sendEmail(emailData);
  }

  async getUserOffers() {
    const userId = this.currentUser?.id;
    if (!userId) throw new Error('User must be authenticated');

    const { data, error } = await this.supabase
      .from('offers')
      .select(`
        *,
        units(*),
        buildings(*)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  }

  async updateOfferStatus(offerId, status, notes = null) {
    const { data, error } = await this.supabase
      .from('offers')
      .update({ 
        status: status,
        updated_at: new Date().toISOString(),
        notes: notes
      })
      .eq('id', offerId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  // Saved Buildings Methods
  async saveBuilding(buildingId) {
    const userId = this.currentUser?.id;
    if (!userId) throw new Error('User must be authenticated');

    const { data, error } = await this.supabase
      .from('saved_buildings')
      .insert({
        user_id: userId,
        building_id: buildingId,
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async unsaveBuilding(buildingId) {
    const userId = this.currentUser?.id;
    if (!userId) throw new Error('User must be authenticated');

    const { error } = await this.supabase
      .from('saved_buildings')
      .delete()
      .eq('user_id', userId)
      .eq('building_id', buildingId);

    if (error) throw error;
  }

  async getSavedBuildings() {
    const userId = this.currentUser?.id;
    if (!userId) throw new Error('User must be authenticated');

    const { data, error } = await this.supabase
      .from('saved_buildings')
      .select(`
        *,
        buildings(*)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  }

  // Make Me Move Methods
  async createMMMlisting(listingData) {
    const userId = this.currentUser?.id;
    if (!userId) throw new Error('User must be authenticated');

    const { data, error } = await this.supabase
      .from('mmm_listings')
      .insert({
        user_id: userId,
        property_address: listingData.propertyAddress,
        building_id: listingData.buildingId,
        unit_number: listingData.unitNumber,
        mmm_price: listingData.mmmPrice,
        min_offer: listingData.minOffer,
        bedrooms: listingData.bedrooms,
        bathrooms: listingData.bathrooms,
        square_footage: listingData.squareFootage,
        features: listingData.features,
        timeline: listingData.timeline,
        display_preference: listingData.displayPreference,
        contact_preference: listingData.contactPreference,
        status: 'active',
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async getUserMMMListings() {
    const userId = this.currentUser?.id;
    if (!userId) throw new Error('User must be authenticated');

    const { data, error } = await this.supabase
      .from('mmm_listings')
      .select(`
        *,
        mmm_offers(*)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  }

  async updateMMMPrice(listingId, newPrice, minOffer = null) {
    const { data, error } = await this.supabase
      .from('mmm_listings')
      .update({ 
        mmm_price: newPrice,
        min_offer: minOffer,
        updated_at: new Date().toISOString()
      })
      .eq('id', listingId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  // Market Data Methods
  async getBuildingAnalytics(buildingId) {
    const { data, error } = await this.supabase
      .from('building_analytics')
      .select('*')
      .eq('building_id', buildingId)
      .single();
    
    if (error) throw error;
    return data;
  }

  async getMarketTrends(neighborhood = null) {
    let query = this.supabase.from('market_trends').select('*');
    
    if (neighborhood) {
      query = query.eq('neighborhood', neighborhood);
    }
    
    const { data, error } = await query.order('date', { ascending: false });
    if (error) throw error;
    return data;
  }

  async getComparableSales(buildingId, bedrooms = null, timeframe = '6 months') {
    let query = this.supabase
      .from('sales')
      .select(`
        *,
        units(*),
        buildings(*)
      `)
      .eq('building_id', buildingId)
      .gte('sale_date', new Date(Date.now() - (timeframe === '6 months' ? 6 : 12) * 30 * 24 * 60 * 60 * 1000).toISOString());
    
    if (bedrooms) {
      query = query.eq('bedrooms', bedrooms);
    }
    
    const { data, error } = await query.order('sale_date', { ascending: false });
    if (error) throw error;
    return data;
  }

  // Email Methods (Integration with Resend)
  async sendEmail(emailData) {
    // This would integrate with Resend API
    const response = await fetch('/api/send-email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailData)
    });

    if (!response.ok) {
      throw new Error('Failed to send email');
    }

    return await response.json();
  }

  // Utility Methods
  formatPrice(price) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(price);
  }

  formatPricePerSqft(price) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(price) + '/sqft';
  }

  calculateDaysOnMarket(listDate) {
    const now = new Date();
    const listed = new Date(listDate);
    const diffTime = Math.abs(now - listed);
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  // Price change calculation
  calculatePriceChange(oldPrice, newPrice) {
    const change = newPrice - oldPrice;
    const percentage = (change / oldPrice) * 100;
    return {
      amount: change,
      percentage: percentage,
      isPositive: change > 0
    };
  }
}

// Initialize global instance
const CM = new CondoMarket();
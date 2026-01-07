-- =====================================================
-- PETPERKS COUPONS SYSTEM - SETUP SQL
-- Run this in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- 1. CREATE INDEXES (Untuk Performance)
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_coupons_is_active ON public.coupons(is_active);
CREATE INDEX IF NOT EXISTS idx_coupons_valid_until ON public.coupons(valid_until);
CREATE INDEX IF NOT EXISTS idx_coupons_code ON public.coupons(code);
CREATE INDEX IF NOT EXISTS idx_user_coupons_user_id ON public.user_coupons(user_id);
CREATE INDEX IF NOT EXISTS idx_user_coupons_coupon_id ON public.user_coupons(coupon_id);
CREATE INDEX IF NOT EXISTS idx_user_coupons_is_used ON public.user_coupons(user_id, is_used);
CREATE INDEX IF NOT EXISTS idx_featured_offers_active ON public.featured_offers(is_active, display_order);
CREATE INDEX IF NOT EXISTS idx_featured_offers_coupon_id ON public.featured_offers(coupon_id);

-- =====================================================
-- 2. ENABLE ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.featured_offers ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. DROP EXISTING POLICIES (jika ada)
-- =====================================================

DROP POLICY IF EXISTS "Anyone can view active coupons" ON public.coupons;
DROP POLICY IF EXISTS "Users can view own coupons" ON public.user_coupons;
DROP POLICY IF EXISTS "Users can collect coupons" ON public.user_coupons;
DROP POLICY IF EXISTS "Users can update own coupons" ON public.user_coupons;
DROP POLICY IF EXISTS "Anyone can view active featured offers" ON public.featured_offers;

-- =====================================================
-- 4. CREATE RLS POLICIES
-- =====================================================

-- COUPONS: Semua user bisa lihat kupon aktif
CREATE POLICY "Anyone can view active coupons"
  ON public.coupons FOR SELECT
  USING (is_active = true);

-- USER_COUPONS: User hanya bisa lihat kupon sendiri
CREATE POLICY "Users can view own coupons"
  ON public.user_coupons FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- USER_COUPONS: User bisa collect kupon (INSERT)
CREATE POLICY "Users can collect coupons"
  ON public.user_coupons FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- USER_COUPONS: User bisa update kupon sendiri
CREATE POLICY "Users can update own coupons"
  ON public.user_coupons FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- FEATURED_OFFERS: Semua orang bisa lihat featured offers aktif
CREATE POLICY "Anyone can view active featured offers"
  ON public.featured_offers FOR SELECT
  USING (is_active = true);

-- =====================================================
-- 5. INSERT SAMPLE COUPONS
-- =====================================================

-- Hapus data lama (opsional, comment jika tidak perlu)
-- DELETE FROM public.user_coupons;
-- DELETE FROM public.featured_offers;
-- DELETE FROM public.coupons;

-- Insert sample coupons
INSERT INTO public.coupons (code, discount_type, discount_value, title, description, min_purchase, category, valid_until, is_active)
VALUES
  ('PETFOOD30', 'percentage', 30, 'Pet Food Discount', 'Get 30% off on all pet food items', 500, 'Pet Food', NOW() + INTERVAL '60 days', true),
  ('TOYS20', 'percentage', 20, 'Pet Toys Sale', 'Save 20% on all pet toys', 999, 'Pet Toys', NOW() + INTERVAL '30 days', true),
  ('GROOMING50', 'percentage', 50, 'Grooming Service', 'Half price on grooming services', 1999, 'Grooming', NOW() + INTERVAL '30 days', true),
  ('FIRSTORDER', 'fixed_amount', 100, 'First Order Discount', 'Get $100 off on your first order', 500, 'General', NOW() + INTERVAL '90 days', true),
  ('FREESHIP', 'fixed_amount', 50, 'Free Shipping', 'Free shipping voucher', 2000, 'Shipping', NOW() + INTERVAL '90 days', true),
  ('ACCESSORIES25', 'percentage', 25, 'Pet Accessories', 'Save on pet accessories', 799, 'Accessories', NOW() + INTERVAL '45 days', true),
  ('VET15', 'percentage', 15, 'Veterinary Services', 'Save 15% on vet consultations', 1000, 'Services', NOW() + INTERVAL '60 days', true),
  ('MEGA40', 'percentage', 40, 'Mega Sale', 'Up to 40% off on selected items', 1500, 'Sale', NOW() + INTERVAL '15 days', true)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- 6. INSERT FEATURED OFFERS (Linked ke Coupons)
-- =====================================================

-- Featured Offer 1: Mega Sale
INSERT INTO public.featured_offers (title, subtitle, description, image_url, background_color, coupon_id, display_order, valid_until, is_active)
SELECT 
  'Get Flat $75 Back',
  'Up to 40% Off',
  'Mega Sale - Limited Time Offer',
  'https://images.unsplash.com/photo-1450778869180-41d0601e046e?w=400&h=200&fit=crop',
  '#6B46C1',
  c.id,
  1,
  NOW() + INTERVAL '30 days',
  true
FROM public.coupons c
WHERE c.code = 'MEGA40'
LIMIT 1;

-- Featured Offer 2: First Order
INSERT INTO public.featured_offers (title, subtitle, description, image_url, background_color, coupon_id, display_order, valid_until, is_active)
SELECT
  'First Order Special',
  'Get $100 Off',
  'New customer exclusive offer',
  'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?w=400&h=200&fit=crop',
  '#10B981',
  c.id,
  2,
  NOW() + INTERVAL '60 days',
  true
FROM public.coupons c
WHERE c.code = 'FIRSTORDER'
LIMIT 1;

-- Featured Offer 3: Pet Food
INSERT INTO public.featured_offers (title, subtitle, description, image_url, background_color, coupon_id, display_order, valid_until, is_active)
SELECT
  'Pet Food Sale',
  '30% Off All Food',
  'Stock up on your pets favorite meals',
  'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400&h=200&fit=crop',
  '#F59E0B',
  c.id,
  3,
  NOW() + INTERVAL '45 days',
  true
FROM public.coupons c
WHERE c.code = 'PETFOOD30'
LIMIT 1;

-- Featured Offer 4: Grooming
INSERT INTO public.featured_offers (title, subtitle, description, image_url, background_color, coupon_id, display_order, valid_until, is_active)
SELECT
  'Grooming Special',
  'Save 50%',
  'Professional grooming services',
  'https://images.unsplash.com/photo-1560807707-8cc77767d783?w=400&h=200&fit=crop',
  '#EC4899',
  c.id,
  4,
  NOW() + INTERVAL '30 days',
  true
FROM public.coupons c
WHERE c.code = 'GROOMING50'
LIMIT 1;

-- Featured Offer 5: Pet Toys
INSERT INTO public.featured_offers (title, subtitle, description, image_url, background_color, coupon_id, display_order, valid_until, is_active)
SELECT
  'Toys Bonanza',
  '20% Off',
  'Fun toys for your pets',
  'https://images.unsplash.com/photo-1544568104-5b7eb8189dd4?w=400&h=200&fit=crop',
  '#3B82F6',
  c.id,
  5,
  NOW() + INTERVAL '30 days',
  true
FROM public.coupons c
WHERE c.code = 'TOYS20'
LIMIT 1;

-- =====================================================
-- 7. GRANT PERMISSIONS
-- =====================================================

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON public.coupons TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.user_coupons TO authenticated;
GRANT SELECT ON public.featured_offers TO authenticated;

-- =====================================================
-- 8. VERIFICATION QUERIES
-- =====================================================

-- Cek jumlah coupons
SELECT COUNT(*) as total_coupons FROM public.coupons;

-- Cek jumlah featured offers
SELECT COUNT(*) as total_featured_offers FROM public.featured_offers;

-- Lihat semua featured offers dengan coupon details
SELECT 
  fo.title,
  fo.subtitle,
  fo.display_order,
  c.code,
  c.discount_type,
  c.discount_value,
  c.title as coupon_title
FROM public.featured_offers fo
LEFT JOIN public.coupons c ON fo.coupon_id = c.id
WHERE fo.is_active = true
ORDER BY fo.display_order;

-- =====================================================
-- SETUP SELESAI!
-- =====================================================
-- Fitur yang sudah aktif:
-- ✅ User bisa lihat featured offers
-- ✅ User bisa collect coupon dengan klik "Collect Now"
-- ✅ User bisa lihat kupon yang sudah di-collect
-- ✅ Validasi otomatis (tidak bisa collect kupon yang sama 2x)
-- ✅ RLS policies untuk keamanan data
-- =====================================================

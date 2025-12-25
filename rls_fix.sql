-- 1. Fix RLS Policy for Products (Allow Authenticated Users to CRUD)
-- Drop existing policy if any likely conflicting
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON "public"."products";
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON "public"."products";
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON "public"."products";

-- Create unrestricted policies (for authenticated users) for MVP
CREATE POLICY "Enable all for authenticated users" ON "public"."products"
AS PERMISSIVE FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 2. Create Storage Bucket for Images
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

-- 3. Storage Policy (Allow public to view, authenticated to upload)
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'product-images' );

create policy "Authenticated Upload"
  on storage.objects for insert
  to authenticated
  with check ( bucket_id = 'product-images' );

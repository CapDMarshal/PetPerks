-- Create order_tracking table
create table if not exists public.order_tracking (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references public.orders(id) on delete cascade not null,
  title text not null,
  description text,
  event_date timestamp with time zone default timezone('utc'::text, now()),
  is_completed boolean default false,
  display_order int default 0
);

-- Enable RLS
alter table public.order_tracking enable row level security;

-- Policy: Users can view tracking for their own orders
create policy "Users can view tracking for own orders"
  on public.order_tracking for select
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_tracking.order_id
      and orders.user_id = auth.uid()
    )
  );

-- Policy: Users can insert tracking for their own orders (Required for initial creation)
create policy "Users can insert tracking for own orders"
  on public.order_tracking for insert
  with check (
    exists (
      select 1 from public.orders
      where orders.id = order_tracking.order_id
      and orders.user_id = auth.uid()
    )
  );

-- Insert sample data for testing (optional, can be removed)
-- You would need a valid order_id to actually insert useful data.
-- This is just a template.
/*
insert into public.order_tracking (order_id, title, description, event_date, is_completed, display_order)
values
  ('ORDER_ID_HERE', 'Order Placed', 'We have received your order', now() - interval '2 days', true, 1),
  ('ORDER_ID_HERE', 'Order Confirmed', 'We has been confirmed', now() - interval '1 day', true, 2),
  ('ORDER_ID_HERE', 'Ready To Ship', 'We are preparing your order', now(), false, 3),
  ('ORDER_ID_HERE', 'Out For Delivery', 'Your order is out for delivery', null, false, 4);
*/

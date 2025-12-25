-- Add products from Home Page (Popular Nearby)
INSERT INTO products (name, price, old_price, image_url, category, description, created_at) VALUES
('Dog Body Belt', 80, 95, 'assets/belt_product.jpg', 'Accessories', 'Durable and comfortable body belt for dogs. Perfect for walks and training.', NOW()),
('Dog Cloths', 80, 95, 'assets/cloths_product.jpg', 'Clothing', 'Stylish and warm clothes for your furry friend.', NOW()),
('Pet Bed For Dog', 80, 95, 'assets/bed_product.jpg', 'Bedding', 'Soft and cozy bed for a good night sleep.', NOW()),
('Dog Chew Toys', 80, 95, 'assets/chew_toys_product.jpg', 'Toys', 'Safe and durable chew toys to keep your pet entertained.', NOW());

-- Add products from Category Screen examples
INSERT INTO products (name, price, old_price, image_url, category, description, created_at) VALUES
('Premium Dog Belt', 45, 60, 'assets/belt.jpg', 'Accessories', 'High quality leather belt.', NOW()),
('Soft Pet Pillow', 30, 45, 'assets/pillow.jpg', 'Bedding', 'Plush pillow for extra comfort.', NOW()),
('Cute Dog Outfit', 55, 75, 'assets/cloths.jpg', 'Clothing', 'Fashionable outfit for small to medium dogs.', NOW()),
('Rubber Chew Bone', 15, 25, 'assets/chew_toys.jpg', 'Toys', 'Long-lasting rubber bone for aggressive chewers.', NOW());

-- Add some Category representatives if needed (Optional, depending if you have a categories table)
-- INSERT INTO categories (name, image_url) VALUES ...

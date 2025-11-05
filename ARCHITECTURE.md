# Architecture Diagram

## New Component Structure

```
┌─────────────────────────────────────────────────────────────┐
│                        PetPerksApp                          │
│                     (MaterialApp)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      MainLayout                             │
│                  (Stateful Widget)                          │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │              IndexedStack                             │ │
│  │         (Preserves State)                             │ │
│  │                                                       │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │ │
│  │  │ HomePageContent│  │ WishlistScreen│  │ CartScreen │ │ │
│  │  │              │  │              │  │            │ │ │
│  │  │   [Active]   │  │  [Preserved] │  │[Preserved] │ │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │ │
│  │                                                       │ │
│  │  ┌──────────────┐  ┌──────────────┐                 │ │
│  │  │CategoryScreen│  │ ProfileScreen│                 │ │
│  │  │              │  │              │                 │ │
│  │  │  [Preserved] │  │  [Preserved] │                 │ │
│  │  └──────────────┘  └──────────────┘                 │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │           BottomNavigationBar                         │ │
│  │  [Home] [Wishlist] [Cart] [Docs] [Profile]          │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Before vs After

### BEFORE (Tightly Coupled)

```
┌─────────────────────────────────────┐
│           HomePage                  │
│   (Stateful Widget)                 │
│                                     │
│   ┌─────────────────────────────┐  │
│   │    AppBar                   │  │
│   └─────────────────────────────┘  │
│                                     │
│   ┌─────────────────────────────┐  │
│   │    Home Content             │  │
│   │    - Banner                 │  │
│   │    - Categories             │  │
│   │    - Products               │  │
│   │    - etc...                 │  │
│   └─────────────────────────────┘  │
│                                     │
│   ┌─────────────────────────────┐  │
│   │  BottomNavigationBar        │  │
│   │  (Not functional)           │  │
│   └─────────────────────────────┘  │
│                                     │
│   State:                            │
│   - _selectedIndex (unused)         │
│   - _isLoading                      │
│   - _scaffoldKey                    │
└─────────────────────────────────────┘

❌ Navigation doesn't work
❌ Can't switch between screens
❌ State management unclear
❌ Hard to add new screens
```

### AFTER (Loosely Coupled)

```
┌──────────────────────────────────────────────────────┐
│                   MainLayout                         │
│               (Stateful Widget)                      │
│                                                      │
│  State: _selectedIndex (controls active screen)     │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │         IndexedStack                           │ │
│  │  Shows one screen, keeps all in memory        │ │
│  │                                                │ │
│  │  Switch based on _selectedIndex:              │ │
│  │  0 → HomePageContent                          │ │
│  │  1 → WishlistScreen                           │ │
│  │  2 → CartScreen                               │ │
│  │  3 → CategoryScreen                           │ │
│  │  4 → ProfileScreen                            │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │    BottomNavigationBar                        │ │
│  │    onTap → Updates _selectedIndex             │ │
│  └────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
             │           │           │
             ▼           ▼           ▼
    ┌─────────────┐ ┌─────────┐ ┌─────────┐
    │HomePageContent│ │Wishlist │ │  Cart   │
    │               │ │ Screen  │ │ Screen  │
    │Each maintains │ │         │ │         │
    │its own state  │ │         │ │         │
    └─────────────┘ └─────────┘ └─────────┘

✅ Navigation works
✅ Easy to switch screens
✅ State preserved per screen
✅ Easy to add new screens
✅ Clean separation of concerns
```

## Data Flow

### Navigation Flow
```
User Taps Bottom Nav Item
         │
         ▼
_onItemTapped(index)
         │
         ▼
setState(() => _selectedIndex = index)
         │
         ▼
IndexedStack shows screen at index
         │
         ▼
Screen preserves its state
```

### State Management Flow (Optional with Provider)
```
┌─────────────────────────────────────────────┐
│         NavigationState                     │
│         (ChangeNotifier)                    │
│                                             │
│  - cartItemCount                            │
│  - wishlistItems                            │
│  - updateCartCount()                        │
│  - addToWishlist()                          │
└──────────────────┬──────────────────────────┘
                   │
     ┌─────────────┼─────────────┐
     │             │             │
     ▼             ▼             ▼
┌─────────┐  ┌──────────┐  ┌─────────┐
│  Home   │  │   Cart   │  │Wishlist │
│ Screen  │  │  Screen  │  │ Screen  │
│         │  │          │  │         │
│ Reads & │  │ Reads &  │  │ Reads & │
│ Updates │  │ Updates  │  │ Updates │
└─────────┘  └──────────┘  └─────────┘
```

## Comparison with Next.js

### Next.js (Web)
```jsx
// pages/_app.js
export default function App({ Component, pageProps }) {
  return (
    <Layout>
      <Component {...pageProps} />
    </Layout>
  )
}

// components/Layout.js
export default function Layout({ children }) {
  const [selectedTab, setSelectedTab] = useState(0);
  
  return (
    <>
      <main>{children}</main>
      <BottomNav 
        selected={selectedTab} 
        onChange={setSelectedTab} 
      />
    </>
  )
}
```

### Flutter (Mobile)
```dart
// lib/main.dart
class PetPerksApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainLayout(),
    );
  }
}

// lib/layout/main_layout.dart
class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
```

## Benefits Visualization

```
┌────────────────────────────────────────────────────────────┐
│                    BENEFITS                                │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. State Preservation                                     │
│     Screen A [State: scroll=100px] ───┐                   │
│            (switch to B)               │ Preserved in      │
│     Screen B [Active]                  │ memory            │
│            (switch back to A)          │                   │
│     Screen A [State: scroll=100px] <───┘ Restored!        │
│                                                            │
│  2. Single Source of Truth                                │
│     BottomNav defined ONCE in MainLayout                  │
│     All screens use the SAME navigation                   │
│     Update once → affects all screens                     │
│                                                            │
│  3. Easy to Extend                                        │
│     New Screen? → Add to _screens list                    │
│     New Nav Item? → Add to items list                     │
│     That's it! ✓                                          │
│                                                            │
│  4. Testable                                              │
│     Test navigation separately from screens               │
│     Test screens separately from navigation               │
│     Mock state easily                                     │
│                                                            │
│  5. Similar to Web Patterns                               │
│     Developers familiar with React/Next.js                │
│     can understand this pattern immediately               │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## File Organization

```
lib/
├── layout/                    # 🆕 Navigation & Layout
│   ├── main_layout.dart       # Main wrapper with bottom nav
│   ├── navigation_state.dart  # Optional state management
│   ├── README.md              # Documentation
│   └── STATE_MANAGEMENT.md    # Advanced patterns
│
├── dashboard/                 # Home-related screens
│   ├── home_page.dart         # ✏️ Modified (now just content)
│   └── product_list_screen.dart
│
├── wishlist/                  # Wishlist features
│   └── wishlist_screen.dart
│
├── cart/                      # Cart features
│   └── cart_screen.dart
│
├── category/                  # Category features
│   └── category_screen.dart
│
├── profile/                   # Profile features
│   └── profile_screen.dart
│
└── main.dart                  # ✏️ Modified (uses MainLayout)
```

## Summary

This architecture follows the **Composition Pattern** where:
- Small, focused components
- Clear responsibilities
- Easy to understand and maintain
- Similar to modern web frameworks
- Scalable for large applications

**Think of it like building with LEGO blocks:**
- Each screen is a block
- MainLayout is the base plate
- Bottom nav connects everything
- You can add/remove blocks easily

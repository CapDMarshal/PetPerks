# Layout Component

This folder contains the main layout component for the PetPerks app, similar to layout components in Next.js.

## MainLayout Component

The `main_layout.dart` file contains the `MainLayout` widget which manages:

- **Bottom Navigation Bar**: Persistent navigation across all screens
- **State Management**: Maintains the selected tab state
- **Screen Switching**: Uses `IndexedStack` to preserve state when switching between screens

### Features

1. **State Preservation**: Using `IndexedStack` ensures that each screen maintains its state when you switch between tabs (similar to React's component state management)

2. **Centralized Navigation**: Bottom navigation is defined once and reused across all screens

3. **Easy to Extend**: Add new screens by:
   - Creating a new screen widget
   - Adding it to the `_screens` list
   - Adding a corresponding `BottomNavigationBarItem`

### Usage

The `MainLayout` is used as the home widget in `main.dart`:

```dart
home: const MainLayout(),
```

### Screen Structure

All screens under the main layout should be simple widgets without their own bottom navigation:

- `HomePageContent` - Home dashboard content
- `WishlistScreen` - User's wishlist
- `CartScreen` - Shopping cart
- `CategoryScreen` - Product categories (Docs)
- `ProfileScreen` - User profile

### Benefits

✅ **Separation of Concerns**: Navigation logic is separate from screen content
✅ **Reusability**: Bottom nav is defined once, used everywhere
✅ **State Management**: Each screen's state is preserved when switching tabs
✅ **Maintainability**: Easy to update navigation without touching individual screens
✅ **Scalability**: Simple to add new screens or modify navigation structure

### Similar to Next.js

This pattern is similar to:

```jsx
// Next.js Layout Component
export default function Layout({ children }) {
  return (
    <>
      <Navigation />
      <main>{children}</main>
    </>
  )
}
```

In Flutter, we achieve the same with `MainLayout` managing the navigation and switching between screen widgets.

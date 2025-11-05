# State Management Example

This example shows how to implement shared state across bottom navigation screens, similar to how you would use Context API or state management in Next.js/React.

## Basic Pattern (Current Implementation)

The current `MainLayout` uses `IndexedStack` which automatically preserves the state of each screen when switching between tabs. This means:

- Each screen maintains its scroll position
- Form data is preserved
- Screen state doesn't reset when switching tabs

## Advanced Pattern: Shared State

If you need to share state between screens (like cart count, wishlist items), here are the recommended approaches:

### Option 1: Using InheritedWidget (Native Flutter)

```dart
// Create a shared state widget
class AppState extends InheritedWidget {
  final int cartCount;
  final Function(int) updateCartCount;
  
  const AppState({
    required this.cartCount,
    required this.updateCartCount,
    required super.child,
    super.key,
  });

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>()!;
  }

  @override
  bool updateShouldNotify(AppState old) => cartCount != old.cartCount;
}

// Wrap MainLayout in main.dart
class PetPerksApp extends StatefulWidget {
  @override
  State<PetPerksApp> createState() => _PetPerksAppState();
}

class _PetPerksAppState extends State<PetPerksApp> {
  int _cartCount = 14;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppState(
        cartCount: _cartCount,
        updateCartCount: (count) => setState(() => _cartCount = count),
        child: const MainLayout(),
      ),
    );
  }
}

// Use in any screen
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    return Text('Cart items: ${appState.cartCount}');
  }
}
```

### Option 2: Using Provider (Recommended)

1. **Add dependency to `pubspec.yaml`:**

```yaml
dependencies:
  provider: ^6.1.0
```

2. **Create a state class (already provided in `navigation_state.dart`):**

```dart
class NavigationState extends ChangeNotifier {
  int _cartItemCount = 14;
  
  int get cartItemCount => _cartItemCount;
  
  void updateCartCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }
}
```

3. **Wrap app with provider in `main.dart`:**

```dart
import 'package:provider/provider.dart';
import 'layout/navigation_state.dart';

class PetPerksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationState(),
      child: MaterialApp(
        home: const MainLayout(),
      ),
    );
  }
}
```

4. **Update `main_layout.dart` to use the state:**

```dart
Widget _buildBottomNav() {
  return Consumer<NavigationState>(
    builder: (context, navState, _) {
      return BottomNavigationBar(
        items: [
          // ... other items
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${navState.cartItemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Cart',
          ),
        ],
        // ... rest of the code
      );
    },
  );
}
```

5. **Use in any screen:**

```dart
// Read state
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<NavigationState>().cartItemCount;
    return Text('Cart items: $cartCount');
  }
}

// Update state
ElevatedButton(
  onPressed: () {
    context.read<NavigationState>().updateCartCount(20);
  },
  child: Text('Update Cart'),
)
```

### Option 3: Using Riverpod (Modern Alternative)

1. **Add dependency:**

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
```

2. **Create providers:**

```dart
final cartCountProvider = StateProvider<int>((ref) => 14);
```

3. **Wrap app:**

```dart
runApp(ProviderScope(child: const PetPerksApp()));
```

4. **Use in widgets:**

```dart
class CartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    return Text('Cart: $cartCount');
  }
}
```

## Comparison with Next.js

### Next.js Context Pattern:
```jsx
// Context Provider
export const AppContext = createContext();

export function Layout({ children }) {
  const [cartCount, setCartCount] = useState(14);
  
  return (
    <AppContext.Provider value={{ cartCount, setCartCount }}>
      {children}
      <BottomNav />
    </AppContext.Provider>
  );
}

// Use in component
function CartScreen() {
  const { cartCount } = useContext(AppContext);
  return <div>Cart: {cartCount}</div>;
}
```

### Flutter Equivalent (Provider):
```dart
// Provider
class NavigationState extends ChangeNotifier {
  int _cartCount = 14;
  int get cartCount => _cartCount;
  void setCartCount(int count) {
    _cartCount = count;
    notifyListeners();
  }
}

// Use in widget
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<NavigationState>().cartCount;
    return Text('Cart: $cartCount');
  }
}
```

## Best Practices

1. **Keep state minimal**: Only store what needs to be shared
2. **Use IndexedStack**: Preserves individual screen states automatically
3. **Choose the right tool**:
   - Simple app → InheritedWidget
   - Medium complexity → Provider
   - Large/complex app → Riverpod or Bloc
4. **Separate concerns**: Keep navigation state separate from business logic
5. **Test state changes**: Ensure notifyListeners() is called when state updates

## Current Implementation Benefits

✅ No external dependencies (pure Flutter)
✅ State preservation with IndexedStack
✅ Easy to upgrade to Provider/Riverpod later
✅ Clean separation of navigation and content
✅ Similar pattern to Next.js layouts

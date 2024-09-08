// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartTotHash() => r'cd1a0b186473e64bdbe586164688dc7f884a0ff9';

/// See also [cartTot].
@ProviderFor(cartTot)
final cartTotProvider = AutoDisposeProvider<int>.internal(
  cartTot,
  name: r'cartTotProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartTotHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CartTotRef = AutoDisposeProviderRef<int>;
String _$cartNotifierHash() => r'9c5b34f84dff825cd9e01f5573f2e124a21f4d95';

/// See also [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider =
    AutoDisposeNotifierProvider<CartNotifier, Set<Product>>.internal(
  CartNotifier.new,
  name: r'cartNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartNotifier = AutoDisposeNotifier<Set<Product>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

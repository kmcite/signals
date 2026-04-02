import 'package:signals/src/surface/surface.dart';

export 'src/surface/surface.dart';

extension SignalExtension<T> on Signal<T?> {
  R choose<R>(R ifNull, R ifNotNull) {
    final value = this();
    if (value == null) {
      return ifNull;
    } else {
      return ifNotNull;
    }
  }
}

extension Extension<T> on T? {
  R choose<R>(R ifNull, R ifNotNull) {
    if (this == null) {
      return ifNull;
    } else {
      return ifNotNull;
    }
  }
}

extension BoolExtension on bool {
  T choose<T>(T ifTrue, T ifFalse) => this ? ifTrue : ifFalse;
}

extension BoolSignalExtension on Signal<bool> {
  T choose<T>(T ifTrue, T ifFalse) => this() ? ifTrue : ifFalse;
  void toggle() => this(!this());
}

extension BoolComputedExtension on Computed<bool> {
  T choose<T>(T ifTrue, T ifFalse) => this() ? ifTrue : ifFalse;
}

extension BoolNullableExtension on bool? {
  T choose<T>(T ifTrue, T ifFalse, T ifNull) {
    if (this == null) {
      return ifNull;
    } else {
      if (this!) {
        return ifTrue;
      } else {
        return ifFalse;
      }
    }
  }
}

extension BoolNullableSignalExtension on Signal<bool?> {
  T choose<T>(T ifTrue, T ifFalse, T ifNull) {
    if (this() == null) {
      return ifNull;
    } else {
      if (this()!) {
        return ifTrue;
      } else {
        return ifFalse;
      }
    }
  }

  /// tristate behavoir
  void toggle() {
    if (this() == null) {
      this(false);
    } else if (this()!) {
      this(!this()!);
    } else {
      this(null);
    }
  }
}

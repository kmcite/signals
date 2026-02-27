final class Stack<T> {
  T value;
  Stack<T>? prev;

  Stack({required this.value, this.prev});
}

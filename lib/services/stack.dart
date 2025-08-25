import 'dart:collection';

class StackCustom<T> {
  final _stack = Queue<T>();

  int get length => _stack.length;

  bool canPop() => _stack.isNotEmpty;

  void clearStack() {
    while (_stack.isNotEmpty) {
      _stack.removeLast();
    }
  }

  void push(T element) {
    _stack.addLast(element);
  }

  Object? pop() {
    if (_stack.isNotEmpty) {
      Object? lastElement = _stack.last;
      _stack.removeLast();
      return lastElement;
    }
    return "";
  }

  Object? peak() => _stack.isEmpty ? "" : _stack.last;
}

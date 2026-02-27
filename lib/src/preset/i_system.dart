import 'link.dart';
import 'reactive_flags.dart';
import 'reactive_node.dart';
import 'stack.dart';

abstract class System {
  const System();
  bool update(ReactiveNode node);
  void notify(ReactiveNode node);
  void unwatched(ReactiveNode node);
  void link(final ReactiveNode dep, final ReactiveNode sub, final int version) {
    final prevDep = sub.depsTail;
    if (prevDep != null && identical(prevDep.dep, dep)) {
      return;
    }
    final nextDep = prevDep != null ? prevDep.nextDep : sub.deps;
    if (nextDep != null && identical(nextDep.dep, dep)) {
      nextDep.version = version;
      sub.depsTail = nextDep;
      return;
    }
    final prevSub = dep.subsTail;
    if (prevSub != null &&
        prevSub.version == version &&
        identical(prevSub.sub, sub)) {
      return;
    }
    final newLink = sub.depsTail = dep.subsTail = Link(
      version: version,
      dep: dep,
      sub: sub,
      prevDep: prevDep,
      nextDep: nextDep,
      prevSub: prevSub,
      nextSub: null,
    );
    if (nextDep != null) {
      nextDep.prevDep = newLink;
    }
    if (prevDep != null) {
      prevDep.nextDep = newLink;
    } else {
      sub.deps = newLink;
    }
    if (prevSub != null) {
      prevSub.nextSub = newLink;
    } else {
      dep.subs = newLink;
    }
  }

  Link? unlink(final Link link, final ReactiveNode sub) {
    final dep = link.dep,
        prevDep = link.prevDep,
        nextDep = link.nextDep,
        nextSub = link.nextSub,
        prevSub = link.prevSub;
    if (nextDep != null) {
      nextDep.prevDep = prevDep;
    } else {
      sub.depsTail = prevDep;
    }
    if (prevDep != null) {
      prevDep.nextDep = nextDep;
    } else {
      sub.deps = nextDep;
    }
    if (nextSub != null) {
      nextSub.prevSub = prevSub;
    } else {
      dep.subsTail = prevSub;
    }
    if (prevSub != null) {
      prevSub.nextSub = nextSub;
    } else if ((dep.subs = nextSub) == null) {
      unwatched(dep);
    }
    return nextDep;
  }

  @pragma('vm:align-loops')
  void propagate(Link link) {
    Link? next = link.nextSub;
    Stack<Link?>? stack;

    top:
    do {
      final sub = link.sub;
      ReactiveFlags flags = sub.flags;

      if ((flags &
              60 /*ReactiveFlags.recursedCheck | ReactiveFlags.recursed | ReactiveFlags.dirty | ReactiveFlags.pending*/ ) ==
          ReactiveFlags.none) {
        sub.flags = flags | ReactiveFlags.pending;
      } else if ((flags &
              12 /*ReactiveFlags.recursedCheck | ReactiveFlags.recursed*/ ) ==
          ReactiveFlags.none) {
        flags = ReactiveFlags.none;
      } else if ((flags & ReactiveFlags.recursedCheck) == ReactiveFlags.none) {
        sub.flags =
            (flags & -9 /*~ReactiveFlags.recursed*/ ) | ReactiveFlags.pending;
      } else if ((flags &
                  48 /*ReactiveFlags.dirty | ReactiveFlags.pending*/ ) ==
              ReactiveFlags.none &&
          isValidLink(link, sub)) {
        sub.flags =
            flags | 40 /*(ReactiveFlags.recursed | ReactiveFlags.pending)*/;
        flags &= ReactiveFlags.mutable;
      } else {
        flags = ReactiveFlags.none;
      }

      if ((flags & ReactiveFlags.watching) != ReactiveFlags.none) {
        notify(sub);
      }

      if ((flags & ReactiveFlags.mutable) != ReactiveFlags.none) {
        final subSubs = sub.subs;
        if (subSubs != null) {
          final nextSub = (link = subSubs).nextSub;
          if (nextSub != null) {
            stack = Stack(value: next, prev: stack);
            next = nextSub;
          }
          continue;
        }
      }

      if (next != null) {
        link = next;
        next = link.nextSub;
        continue;
      }

      while (stack != null) {
        final Stack(:value, :prev) = stack;
        stack = prev;
        if (value != null) {
          link = value;
          next = link.nextSub;
          continue top;
        }
      }

      break;
    } while (true);
  }

  @pragma('vm:align-loops')
  void shallowPropagate(Link link) {
    Link? curr = link;
    do {
      final sub = curr!.sub, flags = sub.flags;
      if ((flags & 48 /*(ReactiveFlags.pending | ReactiveFlags.dirty)*/ ) ==
          ReactiveFlags.pending) {
        sub.flags = flags | ReactiveFlags.dirty;
        if ((flags &
                6 /*(ReactiveFlags.watching | ReactiveFlags.recursedCheck)*/ ) ==
            ReactiveFlags.watching) {
          notify(sub);
        }
      }
    } while ((curr = curr.nextSub) != null);
  }

  @pragma('vm:align-loops')
  bool checkDirty(Link link, ReactiveNode sub) {
    Stack<Link>? stack;
    int checkDepth = 0;
    bool dirty = false;

    top:
    do {
      final dep = link.dep, flags = dep.flags;

      if ((sub.flags & ReactiveFlags.dirty) != ReactiveFlags.none) {
        dirty = true;
      } else if ((flags &
              17 /*(ReactiveFlags.mutable | ReactiveFlags.dirty)*/ ) ==
          17 /*(ReactiveFlags.mutable | ReactiveFlags.dirty)*/ ) {
        if (update(dep)) {
          final subs = dep.subs!;
          if (subs.nextSub != null) {
            shallowPropagate(subs);
          }
          dirty = true;
        }
      } else if ((flags &
              33 /*(ReactiveFlags.mutable | ReactiveFlags.pending)*/ ) ==
          33 /*(ReactiveFlags.mutable | ReactiveFlags.pending)*/ ) {
        if (link.nextSub != null || link.prevSub != null) {
          stack = Stack(value: link, prev: stack);
        }
        link = dep.deps!;
        sub = dep;
        ++checkDepth;
        continue;
      }

      if (!dirty) {
        final nextDep = link.nextDep;
        if (nextDep != null) {
          link = nextDep;
          continue;
        }
      }

      while ((checkDepth--) > 0) {
        final firstSub = sub.subs!, hasMultipleSubs = firstSub.nextSub != null;

        if (hasMultipleSubs) {
          link = stack!.value;
          stack = stack.prev;
        } else {
          link = firstSub;
        }
        if (dirty) {
          if (update(sub)) {
            if (hasMultipleSubs) {
              shallowPropagate(firstSub);
            }
            sub = link.sub;
            continue;
          }
          dirty = false;
        } else {
          sub.flags &= -33 /*~ReactiveFlags.pending*/;
        }
        sub = link.sub;
        final nextDep = link.nextDep;
        if (nextDep != null) {
          link = nextDep;
          continue top;
        }
      }

      return dirty;
    } while (true);
  }

  @pragma('vm:align-loops')
  bool isValidLink(final Link checkLink, final ReactiveNode sub) {
    Link? link = sub.depsTail;
    while (link != null) {
      if (identical(link, checkLink)) return true;
      link = link.prevDep;
    }
    return false;
  }
}

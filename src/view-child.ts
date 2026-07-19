import type { QMLNode } from "./widget-wrappers.js";

let _nativeAppRef: any = null;

export function setNativeAppRef(app: any): void {
  _nativeAppRef = app;
}

export interface ViewChildRef<T extends QMLNode> {
  __viewChild: true;
  selector: string;
  wrapperClass: new () => T;
}

export function viewChild<T extends QMLNode>(
  selector: string,
  wrapperClass: new () => T
): T {
  const ref: ViewChildRef<T> = {
    __viewChild: true,
    selector,
    wrapperClass,
  };
  return ref as unknown as T;
}

export function resolveViewChild<T extends QMLNode>(
  ref: ViewChildRef<T>
): T | null {
  if (!_nativeAppRef) return null;
  const handle = _nativeAppRef.findChild(ref.selector);
  if (!handle) return null;
  const wrapper = new ref.wrapperClass();
  wrapper._attach(_nativeAppRef, handle);
  return wrapper;
}

export function createLazyViewChild<T extends QMLNode>(
  ref: ViewChildRef<T>
): T {
  let _resolved: T | null = null;

  return new Proxy({} as T, {
    get(_target, prop) {
      if (prop === "__viewChild") return true;
      if (prop === "then") return undefined;
      if (_resolved === null) {
        _resolved = resolveViewChild(ref);
      }
      if (_resolved === null) return undefined;
      return (_resolved as any)[prop];
    },
    set(_target, prop, value) {
      if (_resolved === null) {
        _resolved = resolveViewChild(ref);
      }
      if (_resolved === null) return false;
      (_resolved as any)[prop] = value;
      return true;
    },
  }) as T;
}

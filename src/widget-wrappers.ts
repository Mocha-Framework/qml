export abstract class QMLNode {
  protected _nativeApp: any = null;
  protected _handle: number = 0;

  _attach(nativeApp: any, handle: number): void {
    this._nativeApp = nativeApp;
    this._handle = handle;
  }

  getProperty(name: string): string {
    const val = this._nativeApp.getQmlProperty(this._handle, name) ?? "";
    console.log(`[QMLNode] getProperty("${name}", handle=${this._handle}) = "${val}"`);
    return val;
  }

  setProperty(name: string, value: unknown): void {
    console.log(`[QMLNode] setProperty("${name}", handle=${this._handle}, value="${String(value)}")`);
    this._nativeApp.setQmlProperty(this._handle, name, String(value));
  }

  getIntProperty(name: string): number {
    return Number(this.getProperty(name));
  }

  getBoolProperty(name: string): boolean {
    return this.getProperty(name) === "true";
  }
}

export class QMLTextField extends QMLNode {
  get text(): string { return this.getProperty("text"); }
  set text(v: string) { this.setProperty("text", v); }
}

export class QMLTextInput extends QMLNode {
  get text(): string { return this.getProperty("text"); }
  set text(v: string) { this.setProperty("text", v); }
}

export class QMLButton extends QMLNode {
  get enabled(): boolean { return this.getBoolProperty("enabled"); }
  set enabled(v: boolean) { this.setProperty("enabled", v); }
}

export class QMLCheckBox extends QMLNode {
  get checked(): boolean { return this.getBoolProperty("checked"); }
  set checked(v: boolean) { this.setProperty("checked", v); }
}

export class QMLSlider extends QMLNode {
  get value(): number { return this.getIntProperty("value"); }
  set value(v: number) { this.setProperty("value", v); }
}

export class QMLProgressBar extends QMLNode {
  get value(): number { return this.getIntProperty("value"); }
  set value(v: number) { this.setProperty("value", v); }
}

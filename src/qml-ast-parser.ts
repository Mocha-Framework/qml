export interface QmlElement {
  tag: string;
  id: string | null;
  attrs: Record<string, string>;
  body: string;
  children: QmlElement[];
  startLine: number;
}

export interface QmlDocument {
  imports: string[];
  root: QmlElement | null;
}

export class QmlAstParser {
  parse(qml: string): QmlDocument {
    const imports: string[] = [];
    const importRegex = /^\s*import\s+.+$/gm;
    let match;
    while ((match = importRegex.exec(qml)) !== null) {
      imports.push(match[0].trim());
    }

    const stripped = qml.replace(/^\s*import\s+.+$/gm, "").trim();
    const root = this._parseElement(stripped, 0, (name) => imports.some(i => i.includes(name)));
    return { imports, root: root?.element ?? null };
  }

  findElements(root: QmlElement, predicate: (el: QmlElement) => boolean): QmlElement[] {
    const result: QmlElement[] = [];
    this._walk(root, (el) => { if (predicate(el)) result.push(el); });
    return result;
  }

  getTextContent(el: QmlElement): string {
    const lines: string[] = [];
    for (const child of el.children) {
      if (child.tag === "#text") {
        lines.push(child.body);
      }
    }
    return lines.join("\n");
  }

  private _walk(el: QmlElement, fn: (el: QmlElement) => void): void {
    fn(el);
    for (const child of el.children) {
      this._walk(child, fn);
    }
  }

  private _parseElement(qml: string, startOffset: number, isImport: (name: string) => boolean): { element: QmlElement; endOffset: number } | null {
    const trimmed = qml.slice(startOffset).trimStart();
    const offset = startOffset + (qml.length - trimmed.length - startOffset);

    const tagMatch = trimmed.match(/^([A-Z]\w*)\s*\{/);
    if (!tagMatch) return null;
    const tag = tagMatch[1];
    const bodyStart = offset + tagMatch.index! + tagMatch[0].length;

    const body = this._extractBody(qml, bodyStart);
    if (body === null) return null;

    const element = this._buildElement(tag, body.content, body.endOffset, body.line);

    const children: QmlElement[] = [];
    let searchOffset = bodyStart;
    while (searchOffset < body.endOffset) {
      const child = this._parseElement(body.content, searchOffset - bodyStart, isImport);
      if (child) {
        children.push(child.element);
        searchOffset = child.element.startLine >= 0
          ? bodyStart + (child.endOffset - bodyStart)
          : body.endOffset;
      } else {
        // No element at this position — advance past the current line
        // to skip property assignments (id:, anchors:, etc.) that
        // don't start child elements.
        const remaining = body.content.slice(searchOffset - bodyStart);
        const nextNewline = remaining.indexOf("\n");
        if (nextNewline === -1) break;
        searchOffset += nextNewline + 1;
      }
    }
    element.children = children;

    return { element, endOffset: body.endOffset + 1 };
  }

  private _extractBody(qml: string, start: number): { content: string; endOffset: number; line: number } | null {
    let depth = 1;
    let i = start;
    let inSingleString = false;
    let inDoubleString = false;
    let inLineComment = false;
    let inBlockComment = false;
    const lineStart = this._lineAt(qml, start);

    while (i < qml.length && depth > 0) {
      const ch = qml[i];
      const next = qml[i + 1] ?? "";

      if (inLineComment) {
        if (ch === "\n") inLineComment = false;
        i++;
        continue;
      }
      if (inBlockComment) {
        if (ch === "*" && next === "/") { inBlockComment = false; i += 2; }
        else i++;
        continue;
      }
      if (inSingleString) {
        if (ch === "'" && next === "'") i += 2;  // '' escape
        else if (ch === "'") inSingleString = false;
        i++;
        continue;
      }
      if (inDoubleString) {
        if (ch === '"' && next === '"') i += 2;  // "" escape
        else if (ch === '"') inDoubleString = false;
        i++;
        continue;
      }

      if (ch === "/" && next === "/") { inLineComment = true; i += 2; continue; }
      if (ch === "/" && next === "*") { inBlockComment = true; i += 2; continue; }
      if (ch === "'") { inSingleString = true; i++; continue; }
      if (ch === '"') { inDoubleString = true; i++; continue; }

      if (ch === "{") depth++;
      else if (ch === "}") depth--;

      i++;
    }

    const endOffset = depth === 0 ? i - 1 : i;
    return {
      content: qml.slice(start, endOffset),
      endOffset,
      line: lineStart,
    };
  }

  private _buildElement(tag: string, body: string, endOffset: number, line: number): QmlElement {
    const id = this._extractId(body);
    const attrs = this._extractAttrs(body);
    return {
      tag,
      id,
      attrs,
      body,
      children: [],
      startLine: line,
    };
  }

  private _extractId(body: string): string | null {
    const idMatch = body.match(/\bid\s*:\s*(?:"([^"]*)"|(\w+))/);
    return idMatch?.[1] ?? idMatch?.[2] ?? null;
  }

  private _extractAttrs(body: string): Record<string, string> {
    const attrs: Record<string, string> = {};
    const attrRegex = /(\w+)\s*:\s*("[^"]*"|'[^']*'|[^;\n{]+?)(?=[\s;}])/g;
    let m;
    while ((m = attrRegex.exec(body)) !== null) {
      const value = m[2].replace(/^["']|["']$/g, "");
      if (m[1] !== "id") attrs[m[1]] = value;
    }
    return attrs;
  }

  private _lineAt(qml: string, offset: number): number {
    return qml.slice(0, offset).split("\n").length;
  }
}

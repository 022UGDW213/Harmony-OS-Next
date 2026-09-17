// ── Zen design tokens ──────────────────────────────────────────────
// Single source of truth for the Zen app's calm visual language.

export class ZenColors {
  static readonly background: string = '#0B0F0E';
  static readonly surface: string = '#141B19';
  static readonly surfaceSoft: string = '#1B2421';
  static readonly ink: string = '#E9EFEC';
  static readonly muted: string = '#93A29A';
  static readonly faint: string = '#5C6B64';
  static readonly accent: string = '#7FD6B5';
  static readonly breath: string = '#B9EBD4';
  static readonly hold: string = '#8FB8D6';
}

export class ZenSpacing {
  static readonly xs: number = 8;
  static readonly sm: number = 12;
  static readonly md: number = 20;
  static readonly lg: number = 32;
  static readonly xl: number = 48;
}

export class ZenType {
  static readonly hero: number = 44;
  static readonly title: number = 24;
  static readonly body: number = 16;
  static readonly caption: number = 13;
}

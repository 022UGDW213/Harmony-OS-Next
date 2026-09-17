// ── Zen · home ─────────────────────────────────────────────────────
// Minimalist breathing companion. Inhale 4 · hold 4 · exhale 6.

import { ZenSession } from './features/zen/state/ZenSession';
import { BreathCircle } from './features/zen/ui/BreathCircle';
import { ZenControls } from './features/zen/ui/ZenControls';
import { ZenColors, ZenSpacing } from './features/zen/theme/ZenTheme';

@Entry
@Component
struct Index {
  @State session: ZenSession = new ZenSession();

  build() {
    Column({ space: ZenSpacing.lg }) {
      // header
      Column({ space: 6 }) {
        Text('ZEN')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(ZenColors.faint)
          .letterSpacing(6)
        Text('Return to the breath')
          .fontSize(17)
          .fontColor(ZenColors.muted)
      }
      .padding({ top: ZenSpacing.xl })

      BreathCircle({ session: this.session })

      ZenControls({ session: this.session })
    }
    .width('100%')
    .height('100%')
    .padding({ left: ZenSpacing.md, right: ZenSpacing.md, bottom: ZenSpacing.lg })
    .backgroundColor(ZenColors.background)
  }
}

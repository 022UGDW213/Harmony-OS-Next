// ── Breathing circle ───────────────────────────────────────────────
// Expands on inhale, stills on hold, contracts on exhale.

import { ZenSession } from '../state/ZenSession';
import { ZenColors } from '../theme/ZenTheme';

@Component
export struct BreathCircle {
  @ObjectLink session: ZenSession;

  private circleScale(): number {
    switch (this.session.phase) {
      case 'inhale':
        return 1.35;
      case 'exhale':
        return 0.8;
      default:
        return 1.0;
    }
  }

  private circleColor(): string {
    switch (this.session.phase) {
      case 'inhale':
        return ZenColors.breath;
      case 'hold':
        return ZenColors.hold;
      case 'exhale':
        return ZenColors.accent;
      default:
        return ZenColors.surfaceSoft;
    }
  }

  build() {
    Stack() {
      // faint outer ring
      Circle({ width: 220, height: 220 })
        .fillOpacity(0)
        .border({ width: 1, color: ZenColors.faint })
      // breathing core
      Circle({ width: 150, height: 150 })
        .fill(this.circleColor())
        .scale({ x: this.circleScale(), y: this.circleScale() })
        .animation({
          duration: Math.max(500, this.session.phaseDuration * 1000),
          curve: Curve.EaseInOut
        })
        .opacity(this.session.phase === 'idle' ? 0.35 : 0.95)
      // phase label + countdown
      Column({ space: 4 }) {
        Text(this.session.phaseLabel)
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.session.phase === 'idle' ? ZenColors.muted : ZenColors.background)
        if (this.session.running) {
          Text(`${this.session.phaseSecondsLeft}`)
            .fontSize(15)
            .fontColor(this.session.phase === 'idle' ? ZenColors.faint : ZenColors.background)
            .opacity(0.7)
        }
      }
    }
    .width('100%')
    .height(300)
  }
}

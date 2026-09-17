// ── Session controls ───────────────────────────────────────────────
// Start/stop, session length picker, progress and stats.

import { ZenSession } from '../state/ZenSession';
import { BreathEngine } from '../services/BreathEngine';
import { ZenColors, ZenSpacing } from '../theme/ZenTheme';

const LENGTHS: number[] = [60, 180, 300];

@Component
export struct ZenControls {
  @ObjectLink session: ZenSession;
  private engine: BreathEngine | null = null;

  aboutToAppear(): void {
    this.engine = new BreathEngine(this.session);
  }

  aboutToDisappear(): void {
    this.engine?.stop();
  }

  private toggle(): void {
    if (!this.engine) {
      return;
    }
    if (this.session.running) {
      this.engine.stop();
    } else {
      this.engine.start();
    }
  }

  private formatTime(totalSec: number): string {
    const m: number = Math.floor(totalSec / 60);
    const s: number = totalSec % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  }

  build() {
    Column({ space: ZenSpacing.md }) {
      // progress bar
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(4)
          .backgroundColor(ZenColors.surfaceSoft)
          .borderRadius(2)
        Row()
          .width(`${Math.round(this.session.progress * 100)}%`)
          .height(4)
          .backgroundColor(ZenColors.accent)
          .borderRadius(2)
          .animation({ duration: 1000, curve: Curve.Linear })
      }
      .width('100%')

      // stats row
      Row({ space: ZenSpacing.lg }) {
        Column({ space: 2 }) {
          Text(`${this.session.breathsDone}`)
            .fontSize(20)
            .fontWeight(FontWeight.Semibold)
            .fontColor(ZenColors.ink)
          Text('breaths').fontSize(12).fontColor(ZenColors.muted)
        }
        Column({ space: 2 }) {
          Text(this.formatTime(this.session.elapsedSec))
            .fontSize(20)
            .fontWeight(FontWeight.Semibold)
            .fontColor(ZenColors.ink)
          Text('elapsed').fontSize(12).fontColor(ZenColors.muted)
        }
        Column({ space: 2 }) {
          Text(this.formatTime(this.session.sessionLengthSec))
            .fontSize(20)
            .fontWeight(FontWeight.Semibold)
            .fontColor(ZenColors.ink)
          Text('session').fontSize(12).fontColor(ZenColors.muted)
        }
      }

      // length picker (locked while running)
      Row({ space: ZenSpacing.sm }) {
        ForEach(LENGTHS,
          (len: number) => {
            Text(this.formatTime(len))
              .fontSize(14)
              .fontColor(this.session.sessionLengthSec === len ? ZenColors.background : ZenColors.muted)
              .backgroundColor(this.session.sessionLengthSec === len ? ZenColors.accent : ZenColors.surface)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(20)
              .onClick(() => {
                if (!this.session.running) {
                  this.session.sessionLengthSec = len;
                }
              })
          },
          (len: number) => len.toString())
      }
      .opacity(this.session.running ? 0.4 : 1.0)

      // main button
      Button(this.session.running ? 'End session' : 'Begin')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(52)
        .borderRadius(26)
        .backgroundColor(this.session.running ? ZenColors.surfaceSoft : ZenColors.accent)
        .fontColor(this.session.running ? ZenColors.ink : ZenColors.background)
        .onClick(() => this.toggle())
    }
    .width('100%')
  }
}

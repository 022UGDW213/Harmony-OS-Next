// ── Zen session state ──────────────────────────────────────────────
// @Observed so every @ObjectLink consumer re-renders on change.

export type BreathPhase = 'idle' | 'inhale' | 'hold' | 'exhale' | 'done';

@Observed
export class ZenSession {
  phase: BreathPhase = 'idle';
  phaseSecondsLeft: number = 0;
  phaseDuration: number = 0;
  running: boolean = false;
  breathsDone: number = 0;
  sessionLengthSec: number = 180;
  elapsedSec: number = 0;

  get progress(): number {
    return this.sessionLengthSec > 0 ? Math.min(1, this.elapsedSec / this.sessionLengthSec) : 0;
  }

  get phaseLabel(): string {
    switch (this.phase) {
      case 'inhale': return 'Breathe in';
      case 'hold': return 'Hold';
      case 'exhale': return 'Let go';
      case 'done': return 'Complete';
      default: return 'Begin';
    }
  }

  reset(): void {
    this.phase = 'idle';
    this.phaseSecondsLeft = 0;
    this.phaseDuration = 0;
    this.running = false;
    this.breathsDone = 0;
    this.elapsedSec = 0;
  }
}

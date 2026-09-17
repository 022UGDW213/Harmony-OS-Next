// ── Breath state machine ───────────────────────────────────────────
// Pure logic, no UI. Drives a ZenSession through inhale → hold → exhale.

import { ZenSession, BreathPhase } from '../state/ZenSession';

interface PhaseDef {
  name: BreathPhase;
  seconds: number;
}

const PATTERN: PhaseDef[] = [
  { name: 'inhale', seconds: 4 },
  { name: 'hold', seconds: 4 },
  { name: 'exhale', seconds: 6 },
];

export class BreathEngine {
  private timerId: number = -1;
  private phaseIndex: number = 0;

  constructor(private session: ZenSession) {}

  get active(): boolean {
    return this.timerId !== -1;
  }

  start(): void {
    if (this.active) {
      return;
    }
    this.session.reset();
    this.phaseIndex = 0;
    this.enterPhase();
    this.session.running = true;
    this.timerId = setInterval(() => this.tick(), 1000);
  }

  stop(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.session.running = false;
    if (this.session.phase !== 'done') {
      this.session.phase = 'idle';
    }
  }

  private enterPhase(): void {
    const def: PhaseDef = PATTERN[this.phaseIndex];
    this.session.phase = def.name;
    this.session.phaseDuration = def.seconds;
    this.session.phaseSecondsLeft = def.seconds;
  }

  private tick(): void {
    const s: ZenSession = this.session;
    s.elapsedSec += 1;
    s.phaseSecondsLeft -= 1;

    if (s.elapsedSec >= s.sessionLengthSec) {
      s.phase = 'done';
      this.stop();
      return;
    }
    if (s.phaseSecondsLeft <= 0) {
      this.phaseIndex = (this.phaseIndex + 1) % PATTERN.length;
      if (this.phaseIndex === 0) {
        s.breathsDone += 1;
      }
      this.enterPhase();
    }
  }
}

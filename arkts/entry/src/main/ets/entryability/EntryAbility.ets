// ── Zen · EntryAbility ───────────────────────────────────────────────
// Stage-model UIAbility. Loads the Zen home page (pages/Index).

import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'ZenAbility', 'onCreate, want: %{public}s', JSON.stringify(want) ?? '');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'ZenAbility', 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'ZenAbility', 'onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'ZenAbility', 'loadContent failed: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(DOMAIN, 'ZenAbility', 'loadContent succeeded');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'ZenAbility', 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'ZenAbility', 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'ZenAbility', 'onBackground');
  }
}

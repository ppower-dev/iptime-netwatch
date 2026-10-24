#!/bin/bash
launchctl bootout "gui/$(id -u)/local.netwatch" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/local.netwatch.plist"
for f in netwatch netwatch-config netwatch-notify iptime; do
  rm -f "$HOME/.local/bin/$f"
done
echo "서비스와 명령을 지웠어요."
echo "설정(~/.config/netwatch), 기록(~/Library/Logs/netwatch.log), 키체인 계정(iptime-admin)은 남겨 뒀어요. 필요 없으면 직접 지워 주세요."

#!/bin/bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONF_DIR="$HOME/.config/netwatch"
PLIST="$HOME/Library/LaunchAgents/local.netwatch.plist"

[ "$(uname)" = Darwin ] || { echo "macOS 전용이에요." >&2; exit 1; }

mkdir -p "$BIN_DIR" "$CONF_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
for f in netwatch netwatch-config netwatch-notify iptime; do
  ln -sfn "$REPO/bin/$f" "$BIN_DIR/$f"
done
echo "설치  $BIN_DIR/{netwatch,iptime,netwatch-notify}"

if [ ! -f "$CONF_DIR/config" ]; then
  cp "$REPO/config.example" "$CONF_DIR/config"
  echo "생성  $CONF_DIR/config (필요하면 열어서 고쳐 주세요)"
fi

cat >"$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>local.netwatch</string>
  <key>ProgramArguments</key>
  <array><string>$BIN_DIR/netwatch</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/netwatch.err</string>
</dict>
</plist>
PLIST
launchctl bootout "gui/$(id -u)/local.netwatch" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "실행  launchd 서비스 local.netwatch"

echo
. "$CONF_DIR/config"
if ! /usr/bin/security find-generic-password -s "${KEYCHAIN_SERVICE:-iptime-admin}" >/dev/null 2>&1; then
  echo "다음 단계: 공유기 관리자 계정을 키체인에 저장 → README의 '2. 공유기 계정 저장하기'"
fi
[ -s "$CONF_DIR/router-mac" ] || echo "다음 단계: 집 와이파이에 연결한 채로 'iptime pin' 실행"
echo "끝! 기록은 ~/Library/Logs/netwatch.log 에 남아요."

#!/usr/bin/env bash
# Commit 2: Flutter 환경 점검 스크립트
# 사용법: ./scripts/check_flutter_env.sh

set -e
cd "$(dirname "$0")/.."

echo "=== CrossFit Posture Coach - Flutter 환경 점검 ==="
echo ""

if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter가 PATH에 없습니다."
  echo "   Flutter SDK를 설치하고 PATH에 flutter/bin을 추가하세요."
  echo "   참고: docs/FLUTTER_SETUP.md"
  exit 1
fi

echo "✓ Flutter 발견: $(which flutter)"
flutter --version
echo ""

echo "--- flutter doctor -v ---"
flutter doctor -v
echo ""

if [ ! -d "android" ] || [ ! -d "ios" ]; then
  echo "⚠ android/ 또는 ios/ 폴더가 없습니다."
  echo "   다음 명령으로 플랫폼 코드를 생성하세요:"
  echo "   flutter create . --project-name posture_coach --org com.crossfit.posturecoach"
  echo ""
fi

echo "--- flutter pub get ---"
flutter pub get
echo ""

echo "=== 점검 완료 ==="
echo "에뮬레이터/기기 연결 후 'flutter run'으로 앱을 실행하세요."

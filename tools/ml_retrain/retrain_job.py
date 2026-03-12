# Commit 28: 재학습 루프 – 트리거 로직 및 잡 뼈대

from __future__ import annotations

import datetime as dt
from typing import Optional


def should_retrain_now(
    *,
    label_count: int,
    last_retrain_at: Optional[dt.datetime],
    now: dt.datetime,
    min_labels: int = 50,
    min_hours_since_last: int = 6,
) -> bool:
  """재학습을 수행해야 하는지 여부를 판단한다.

  Args:
      label_count: 현재 누적된 라벨(ml_labels/feedback) 개수.
      last_retrain_at: 마지막 재학습 시각 (없으면 None).
      now: 현재 시각.
      min_labels: 재학습을 실행하기 위한 최소 라벨 개수.
      min_hours_since_last: 마지막 재학습 이후 최소 시간(시간 단위).
  """
  if label_count < min_labels:
    return False

  if last_retrain_at is None:
    return True

  hours_since_last = (now - last_retrain_at).total_seconds() / 3600.0
  return hours_since_last >= min_hours_since_last


def run_retrain_if_needed():
  """실제 배포 환경에서 주기적으로 호출될 재학습 잡 뼈대.

  현재는 의존성 없이 구조만 정의해 두고,
  Firestore/Storage 연동 및 TensorFlow 학습 코드는 추후 Commit에서 채운다.
  """
  # TODO(Commit 29+): Firestore에서 ml_labels/feedback 개수와
  # 마지막 재학습 시각을 읽어와 should_retrain_now()로 체크한 뒤,
  # build_training_dataset() + 실제 모델 재학습을 실행한다.
  pass


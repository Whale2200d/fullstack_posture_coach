# Commit 28: 재학습 루프 – 트리거 로직 TDD
#
# 조건:
# - ml_labels(또는 feedback) 문서 수가 최소 N개 이상이고
# - 마지막 재학습 이후 최소 M시간이 지났을 때만 재학습을 수행한다.

import datetime as dt
import unittest

from retrain_job import should_retrain_now


class RetrainJobTest(unittest.TestCase):
  def test_does_not_retrain_when_not_enough_labels(self):
    now = dt.datetime(2026, 3, 10, 12, 0, 0)
    last = now - dt.timedelta(hours=10)
    self.assertFalse(
      should_retrain_now(
        label_count=49,
        last_retrain_at=last,
        now=now,
        min_labels=50,
        min_hours_since_last=6,
      )
    )

  def test_does_not_retrain_when_too_soon_since_last(self):
    now = dt.datetime(2026, 3, 10, 12, 0, 0)
    last = now - dt.timedelta(hours=2)
    self.assertFalse(
      should_retrain_now(
        label_count=100,
        last_retrain_at=last,
        now=now,
        min_labels=50,
        min_hours_since_last=6,
      )
    )

  def test_retrains_when_labels_and_time_conditions_met(self):
    now = dt.datetime(2026, 3, 10, 12, 0, 0)
    last = now - dt.timedelta(hours=8)
    self.assertTrue(
      should_retrain_now(
        label_count=80,
        last_retrain_at=last,
        now=now,
        min_labels=50,
        min_hours_since_last=6,
      )
    )


if __name__ == "__main__":
  unittest.main()


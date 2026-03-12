# Commit 27: ML 재학습 – 데이터셋 빌더 TDD
#
# 이 테스트는 Firestore feedback 문서 형태의 더미 데이터를 받아
# (features, labels) 형태의 학습용 데이터셋을 만드는 함수를 검증한다.

import unittest

from ml_retrain.dataset_builder import build_training_dataset


class DatasetBuilderTest(unittest.TestCase):
  def test_build_training_dataset_maps_feedback_to_features_and_labels(self):
    # Firestore feedback 문서 더미 (docs/DB_SCHEMA_FIRESTORE.md 섹션 6 참조)
    docs = [
      {
        "sessionId": "session_001",
        "userId": "user_1",
        "coachId": "coach_1",
        "label": {"isPositive": True, "score": 5},
      },
      {
        "sessionId": "session_002",
        "userId": "user_2",
        "coachId": "coach_1",
        "label": {"isPositive": False, "score": 2},
      },
    ]

    X, y = build_training_dataset(docs)

    # 샘플 수
    self.assertEqual(len(X), 2)
    self.assertEqual(len(y), 2)

    # features: score를 포함하고, userId/coachId는 포함되지 않는다.
    self.assertIn("score", X[0])
    self.assertNotIn("userId", X[0])
    self.assertNotIn("coachId", X[0])

    # labels: isPositive -> 1/0 으로 매핑
    self.assertEqual(y[0], 1)
    self.assertEqual(y[1], 0)


if __name__ == "__main__":
  unittest.main()


# Commit 27: ML 재학습 – Firestore feedback → 학습용 데이터셋 변환
#
# 이 모듈은 Firestore feedback 문서 리스트를 받아
# 간단한 (features, labels) 데이터셋으로 변환한다.
#
# - features: 현재는 score 값만 포함 (확장 시 랜드마크/각도 요약 추가 예정)
# - labels: label.isPositive (True/False) → 1/0 으로 매핑

from typing import Dict, List, Tuple


def build_training_dataset(
    feedback_docs: List[Dict],
) -> Tuple[List[Dict], List[int]]:
  """
  Args:
      feedback_docs: Firestore feedback 문서 dict 리스트.
          각 문서는 최소한 다음 구조를 가진다고 가정한다.
          {
              "label": {
                  "isPositive": bool,
                  "score": int,
              },
              ...
          }

  Returns:
      X: feature dict 리스트. 현재는 {"score": int} 형태.
      y: label 리스트. isPositive=True → 1, False/None → 0.
  """
  X: List[Dict] = []
  y: List[int] = []

  for doc in feedback_docs:
    label = doc.get("label") or {}
    is_positive = label.get("isPositive")
    score = label.get("score")

    # feature: 점수만 일단 사용 (추후 각도/템포 등 추가 예정)
    X.append({"score": int(score) if score is not None else 0})

    # label: bool → 1/0
    y.append(1 if is_positive else 0)

  return X, y


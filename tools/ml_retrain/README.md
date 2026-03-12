# Commit 27 – ML 재학습 기본 셋업 (TensorFlow Lite용 데이터 전처리 뼈대)

이 디렉터리는 **코치 피드백 기반 ML 재학습 파이프라인**의 최소 뼈대를 담습니다.

## 구성

- `dataset_builder.py`
  - Firestore `feedback` 문서 리스트를 입력 받아
  - 학습용 `(features, labels)` 데이터셋으로 변환하는 헬퍼 함수 제공.
- `test_dataset_builder.py`
  - 위 함수가 **isPositive/score → 1/0 라벨 + feature** 로 잘 매핑되는지 검증하는 Python `unittest`.
- `retrain_job.py`
  - 재학습 실행 여부를 판단하는 `should_retrain_now` 와,
  - 실제 배치 환경에서 주기적으로 호출될 `run_retrain_if_needed` 뼈대 함수 정의.
- `test_retrain_job.py`
  - 라벨 개수/시간 조건을 바꿔가며 `should_retrain_now` 동작을 검증하는 테스트.

## 사용 예시 (로컬에서 수동 실행)

> 이 프로젝트는 Flutter가 메인이라 Python 환경/pytest는 자동 세팅되어 있지 않습니다.  
> 아래 명령은 **옵션**이며, Python 3+ 와 `unittest` 표준 라이브러리만 있으면 동작합니다.

```bash
cd tools/ml_retrain

# 테스트 실행
python -m unittest test_dataset_builder.py

# 재학습 트리거 로직 테스트
python -m unittest test_retrain_job.py
```

## 데이터 흐름과 연계

`docs/ML_RETRAINING_FLOW.md` 와 `docs/DB_SCHEMA_FIRESTORE.md` 에 정의된 흐름과 매핑하면:

1. 앱/코치 대시보드에서 입력된 피드백은 Firestore `feedback` 컬렉션에 저장됩니다.
2. Cloud Functions 또는 별도 배치 스크립트에서 `feedback` 문서를 조회합니다.
3. 이 때 `dataset_builder.build_training_dataset(docs)` 를 호출해:
   - `X`: `[{ "score": 5 }, { "score": 2 }, ...]`
   - `y`: `[1, 0, ...]` (좋아요/싫어요 → 1/0)
4. 그 후 TensorFlow/PyTorch 등으로 실제 TFLite 재학습을 수행합니다.

향후 확장 시:

- `X`에 MediaPipe 각도/템포 등 feature를 추가
- `y`에 점수(1~5) 회귀 타깃을 함께 사용
- 별도 `retrain.py` 또는 노트북에서 모델 로드/학습/평가/배포 코드 구현


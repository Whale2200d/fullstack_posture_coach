# Commit 32: Ultralytics YOLOv8 결과 파서 TDD

import unittest

from ultralytics_result_parser import extract_keypoints_from_result


class UltralyticsResultParserTest(unittest.TestCase):
  def test_extracts_keypoints_from_fake_result(self):
    fake_result = type("R", (), {})()
    fake_result.keypoints = [
      [100.0, 200.0, 0.9, 150.0, 250.0, 0.8],
      [10.0, 20.0, 0.5, 30.0, 40.0, 0.6],
    ]

    keypoints_list = extract_keypoints_from_result(fake_result)

    self.assertEqual(len(keypoints_list), 2)
    self.assertEqual(len(keypoints_list[0]), 6)
    self.assertEqual(keypoints_list[0][0], 100.0)
    self.assertEqual(keypoints_list[1][3], 30.0)


if __name__ == "__main__":
  unittest.main()


import json
from pathlib import Path
import shutil
import tempfile
import unittest

from validate_content import ROOT, validate


class ContentGateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for directory in ('assets/data/lessons', 'lib/data/constants', 'lib/logic'):
            shutil.copytree(ROOT / directory, self.root / directory)

    def change(self, update):
        path = self.root / 'assets/data/lessons/A1_CH01_L01.json'
        lesson = json.loads(path.read_text())
        update(lesson)
        path.write_text(json.dumps(lesson))

    def test_current_catalog(self):
        catalog, errors = validate(self.root)
        self.assertEqual(errors, [])
        self.assertEqual(len(catalog), 8)

    def test_missing_prerequisite(self):
        self.change(lambda d: d.update(prerequisites=['MISSING']))
        self.assertTrue(any('missing prerequisite' in e for e in validate(self.root)[1]))

    def test_cycle(self):
        self.change(lambda d: d.update(prerequisites=['A1_CH02_L01']))
        self.assertTrue(any('cycle' in e for e in validate(self.root)[1]))

    def test_absent_recording(self):
        self.change(lambda d: d['lesson_flow']['input'].update(audio_url='assets/audio/missing.mp3'))
        self.assertTrue(any('missing audio' in e for e in validate(self.root)[1]))

    def test_remote_recording(self):
        self.change(lambda d: d['lesson_flow']['input'].update(audio_url='https://example.com/audio.mp3'))
        self.assertTrue(any('remote audio' in e for e in validate(self.root)[1]))

    def test_missing_reading(self):
        path = self.root / 'assets/data/lessons/A1_CH04_L01.json'
        lesson = json.loads(path.read_text())
        lesson['lesson_flow']['input'].pop('reading_text_en')
        path.write_text(json.dumps(lesson))
        self.assertTrue(any('missing input text' in e for e in validate(self.root)[1]))

    def test_unregistered_asset(self):
        (self.root / 'assets/data/lessons/A1_CH04_L01.json').unlink()
        self.assertTrue(any('Registry' in e for e in validate(self.root)[1]))

    # ── Danh mục audio Hugging Face ──────────────────────────────────────

    def change_audio_catalog(self, old, new):
        path = self.root / 'lib/data/constants/audio_catalog.dart'
        self.assertIn(old, path.read_text())
        path.write_text(path.read_text().replace(old, new))

    def test_audio_catalog_convention_violation(self):
        self.change_audio_catalog(
            "fileName: 'A1_CH01_L01_input_01.mp3'",
            "fileName: 'wrong_name.mp3'",
        )
        errors = validate(self.root)[1]
        self.assertTrue(any('must follow' in e for e in errors))

    def test_audio_catalog_missing_lesson(self):
        self.change_audio_catalog(
            "lessonId: 'A1_CH01_L01'",
            "lessonId: 'ZZ_CH99_L01'",
        )
        errors = validate(self.root)[1]
        self.assertTrue(any('missing lesson' in e for e in errors))

    def test_audio_catalog_duplicate_file(self):
        self.change_audio_catalog(
            "fileName: 'A1_CH02_L01_input_01.mp3'",
            "fileName: 'A1_CH01_L01_input_01.mp3'",
        )
        errors = validate(self.root)[1]
        self.assertTrue(any('duplicate file' in e for e in errors))

    def test_audio_catalog_zero_estimate(self):
        self.change_audio_catalog(
            'estimatedBytes: _estimatedInputClipBytes,',
            'estimatedBytes: 0,',
        )
        errors = validate(self.root)[1]
        self.assertTrue(any('estimatedBytes' in e for e in errors))


if __name__ == '__main__':
    unittest.main()

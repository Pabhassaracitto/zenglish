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


if __name__ == '__main__':
    unittest.main()

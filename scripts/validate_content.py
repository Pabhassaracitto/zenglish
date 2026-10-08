#!/usr/bin/env python3
"""Offline content gate. Run from any directory; no third-party dependencies."""
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def validate(root=ROOT):
    errors = []
    catalog = {}
    registry = (root / 'lib/data/constants/lesson_asset_registry.dart').read_text()
    registered = re.findall(r"\$_basePath/([^']+\.json)", registry)
    files = sorted((root / 'assets/data/lessons').glob('*.json'))
    if len(registered) != len(set(registered)):
        errors.append('Duplicate registry paths')
    if set(registered) != {p.name for p in files}:
        errors.append('Registry and bundled lesson files differ')
    for path in files:
        try:
            lesson = json.loads(path.read_text())
            ident = lesson['lesson_id']
            assert isinstance(ident, str) and path.stem == ident
            assert ident not in catalog, 'duplicate ID'
            catalog[ident] = lesson
            for field in ('title_en', 'title_vi', 'authenticity_reminder'):
                assert isinstance(lesson[field], str) and lesson[field].strip(), field
            flow = lesson['lesson_flow']
            for phase in ('input', 'pattern', 'guided', 'output'):
                assert flow[phase]['title'] and flow[phase]['description'], phase
            assert flow['input'].get('sample_dialogues') or flow['input'].get('reading_text_en'), 'missing input text'
            assert flow['pattern']['core_patterns'], 'missing patterns'
            assert flow['guided']['interview_steps'], 'missing guided steps'
            assert flow['output']['prompt_for_user'], 'missing output prompt'
            assert flow['output']['evaluation_criteria'], 'missing evaluation criteria'
            assert isinstance(lesson['prerequisites'], list), 'prerequisites must be a list'
            for vocab in lesson['vocabulary']:
                for field in ('en', 'vi', 'example_en'):
                    assert isinstance(vocab[field], str) and vocab[field].strip(), field
            audio = flow['input'].get('audio_url')
            if audio:
                # This catalog ships as offline beta: no remote/absent recordings.
                assert isinstance(audio, str) and not audio.startswith(('http:', 'https:')), 'remote audio in offline catalog'
                asset = audio.removeprefix('asset:///')
                resolved = (root / asset).resolve()
                assert resolved.is_relative_to((root / 'assets').resolve()), 'audio outside assets'
                assert resolved.is_file(), 'missing audio asset'
        except (ValueError, KeyError, TypeError, AssertionError) as error:
            errors.append(f'{path.name}: {error}')
    visiting, done = set(), set()

    def visit(ident):
        if ident in visiting:
            errors.append(f'Prerequisite cycle at {ident}')
            return
        if ident in done:
            return
        visiting.add(ident)
        dependencies = catalog[ident].get('prerequisites', [])
        if not isinstance(dependencies, list):
            dependencies = []
        for dep in dependencies:
            if not isinstance(dep, str) or dep not in catalog:
                errors.append(f'{ident}: missing prerequisite {dep}')
            else:
                visit(dep)
        visiting.remove(ident)
        done.add(ident)

    for ident in catalog:
        visit(ident)
    router = (root / 'lib/logic/content_router.dart').read_text()
    for ident in set(re.findall(r"'([A-C][12]_?CH\d+_L\d+)'", router)):
        if ident not in catalog:
            errors.append(f'Placement route references missing lesson {ident}')
    errors.extend(validate_audio_catalog(root, catalog))
    return catalog, errors


def validate_audio_catalog(root, catalog):
    """Kiểm tra danh mục audio Hugging Face (lib/data/constants/audio_catalog.dart).

    Quy ước: mỗi entry khai báo lessonId, fileName, estimatedBytes;
    fileName phải đúng dạng `<LESSON_ID>_input_NN.mp3` và trỏ về bài có thật.
    """
    errors = []
    audio_dart = root / 'lib/data/constants/audio_catalog.dart'
    if not audio_dart.exists():
        return errors
    entries = re.findall(
        r"RemoteAudioFile\(\s*lessonId:\s*'([^']+)'\s*,"
        r"\s*fileName:\s*'([^']+)'\s*,"
        r"\s*estimatedBytes:\s*([A-Za-z0-9_]+)",
        audio_dart.read_text(),
    )
    seen_files = set()
    for lesson_id, file_name, estimated in entries:
        if file_name in seen_files:
            errors.append(f'audio catalog: duplicate file {file_name}')
        seen_files.add(file_name)
        if lesson_id not in catalog:
            errors.append(
                f'audio catalog: {file_name} references missing lesson {lesson_id}'
            )
        if not re.fullmatch(rf'{re.escape(lesson_id)}_input_\d{{2}}\.mp3', file_name):
            errors.append(
                f'audio catalog: {file_name} must follow <LESSON_ID>_input_NN.mp3'
            )
        if estimated.isdigit() and int(estimated) <= 0:
            errors.append(f'audio catalog: {file_name} estimatedBytes must be positive')
    return errors


if __name__ == '__main__':
    catalog, errors = validate()
    for error in errors:
        print(f'ERROR: {error}')
    if errors:
        raise SystemExit(1)
    print(f'PASS: {len(catalog)} lessons; registry, prerequisites, routes, text and audio references valid.')
    pending = [key for key, lesson in catalog.items()
               if not lesson['lesson_flow']['input'].get('audio_url')]
    print(f'INFO: {len(pending)} lessons have no bundled recording.')
    audio_dart = ROOT / 'lib/data/constants/audio_catalog.dart'
    if audio_dart.exists():
        covered = set(re.findall(r"lessonId:\s*'([^']+)'", audio_dart.read_text()))
        remote_pending = [key for key in pending if key not in covered]
        print(f'INFO: {len(pending) - len(remote_pending)} of those stream/download from the Hugging Face catalog; '
              f'{len(remote_pending)} rely on the on-device TTS fallback.')

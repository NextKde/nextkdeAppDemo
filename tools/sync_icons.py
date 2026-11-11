#!/usr/bin/env python3
"""Copy the canonical icon module into an existing Kos.Ui source snapshot.
Only icon files and the CMake link are changed. Run from a reviewed source revision;
consumer repositories retain their other UI API/material revisions.
"""
import argparse
from pathlib import Path
import shutil
from icon_migration import migrate

SOURCE = Path(__file__).resolve().parents[1] / 'shared/qml'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('target_ui', type=Path, help='Target shared/qml directory')
args = parser.parse_args()
target = args.target_ui.resolve()
if target == SOURCE.resolve():
    parser.error('Source and target must differ')
if not (target / 'CMakeLists.txt').is_file() or not (target / 'controls/VectorIcon.qml').is_file():
    parser.error('Target is not a Kos.Ui source snapshot')
shutil.copytree(SOURCE.parent / 'Icons', target.parent / 'Icons', dirs_exist_ok=True)
shutil.copyfile(SOURCE / 'controls/VectorIcon.qml', target / 'controls/VectorIcon.qml')
p = target / 'CMakeLists.txt'
s = p.read_text()
if 'add_subdirectory(../Icons ' not in s:
    s = 'if(NOT TARGET kos_icons)\n    add_subdirectory(../Icons kos-icons)\nendif()\n\n' + s
if 'Kos::Icons Kos::IconsPlugin' not in s:
    s = s.replace('target_link_libraries(kos_ui PUBLIC', 'target_link_libraries(kos_ui PUBLIC\n    Kos::Icons Kos::IconsPlugin')
p.write_text(s)
p = target / 'foundation/KosSidebarToggle.qml'
if p.exists():
    s = p.read_text()
    marker = '    contentItem: Item {'
    if marker in s and 'Kos.Icons' not in s:
        s = s.replace('import QtQuick\n', 'import QtQuick\nimport "../../Icons" as Symbols\n', 1)
        s = s[:s.index(marker)] + '    contentItem: Symbols.Icon { name: "sidebar_left"; color: root.glyphColor; size: 18 }\n}\n'
        p.write_text(s)
migrate(target)
facade = target.parents[1] / 'demo/Kos/Icons'
if facade.parent.is_dir() and not facade.exists():
    facade.symlink_to('../../shared/Icons')
print('Synced canonical Kos.Icons into', target)

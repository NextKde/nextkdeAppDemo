#!/usr/bin/env python3
"""VM/CI source audit of project-owned QML icon usage.

Run with one or more checkout roots. This inventories procedural artwork and
flags character icons, dynamic glyph text and unknown literal icon names.
It does not treat data visualization, mathematical text, user artwork or native
platform cursors as replaceable icons, and does not claim visual acceptance.
"""
import argparse
import json
from pathlib import Path
import re

SYMBOLS = re.compile(r'[✓✔✕×➕−›‹▶◀♫♪⌕⚙☀☂☁⚠♥★☆⌃⌄↻◷⌁❖≋▦⧉⌂]')
TEXT_TYPES = {'Text', 'Label', 'GlassText', 'ShellText', 'Button', 'ToolButton', 'KosToolButton', 'DeckButton'}
SKIP = {'third_party', 'vendor', 'build', 'tmp', '.git', '.build', 'node_modules', 'tests'}

def end_block(source, opening):
    depth = 1; i = opening + 1; quote = None
    while i < len(source):
        ch = source[i]
        if quote:
            if ch == '\\': i += 2; continue
            if ch == quote: quote = None
        elif source.startswith('//', i):
            newline = source.find('\n', i)
            i = len(source) if newline < 0 else newline
            continue
        elif source.startswith('/*', i):
            i = source.find('*/', i + 2) + 2
            continue
        elif ch in '\"\'`': quote = ch
        elif ch == '{': depth += 1
        elif ch == '}':
            depth -= 1
            if not depth: return i + 1
        i += 1
    return len(source)

def inspect(root, known):
    findings = []; artwork = []; count = 0
    for path in sorted(root.rglob('*.qml')):
        rel = path.relative_to(root)
        if path.is_symlink() or any(p in SKIP or p.startswith('build-') for p in rel.parts): continue
        if not any(p in {'qml', 'shell', 'shared', 'settings', 'demo'} for p in rel.parts): continue
        count += 1; source = path.read_text()
        blocks = []
        for match in re.finditer(r'\b([A-Z]\w*(?:\.\w+)?)\s*\{', source):
            opening = source.index('{', match.start())
            blocks.append((opening, end_block(source, opening), match[1]))
        for match in re.finditer(r'(?<![\w.])(?:text|name|iconName)\s*:\s*([^\n;]+)', source):
            # Ignore comments and bindings in enclosing objects; use innermost owner.
            line_start = source.rfind('\n', 0, match.start()) + 1
            if '//' in source[line_start:match.start()]: continue
            owners = [b for b in blocks if b[0] < match.start() < b[1]]
            if not owners: continue
            opening, closing, kind = max(owners, key=lambda b:b[0])
            expression = match[1].strip().rstrip(' }')
            prop = match[0].split(':', 1)[0].strip()
            literals = re.findall(r'"([^"\n]*)"', expression)
            reason = None
            if prop == 'text' and (kind in TEXT_TYPES or kind.endswith('Button')):
                if kind.endswith('Button') and re.search(r'contentItem:\s*(?:Symbols.Icon|BundledIcon)', source[opening:closing]): continue
                if expression == 'IconRegistry.glyph(root.name, root.filled)' and rel.as_posix().endswith('Icons/Icon.qml'): continue
                # Multiplication in widget dimensions and minus in elapsed/remaining time are data.
                data_text = any(x in expression for x in ['displayColumns', 'displayRows', 'durationMs', 'positionMs', '.join(" › ")'])
                if not data_text and any(SYMBOLS.search(s) for s in literals): reason = 'character icon in text'
                if re.search(r'\b(?:symbol|glyph|widgetSymbols|symbols)\b', expression) or expression.startswith('modelData.icon'):
                    reason = 'dynamic icon rendered through a text font'
                if expression in {'"+"', '"-"', '"!"'}: reason = 'punctuation-only action needs review'
            if (prop == 'name' and kind in {'Symbols.Icon', 'VectorIcon', 'BundledIcon', 'CalculatorIcon'}) or prop == 'iconName':
                if 'BundledIcons.roleName(' in expression: continue
                returned = re.sub(r'(?:===|!==|==|!=)\s*"[^"]*"|"[^"]*"\s*:', '', expression)
                literals = re.findall(r'"([^"\n]*)"', returned)
                unknown = [s for s in literals if s and s not in known and s not in {'placeholder-dot','nextkde','kos-calendar','kos-music','kos-weather','default-cover'}]
                if unknown: reason = 'unknown icon name: ' + ', '.join(unknown)
            if reason: findings.append({'file': str(rel), 'line':source.count('\n',0,match.start())+1, 'reason':reason, 'binding':match[0]})
        for match in re.finditer(r'\b(?:Canvas|ShapePath|PathSvg)\s*\{|data:image/svg',source):
            artwork.append({'file':str(rel),'line':source.count('\n',0,match.start())+1,'kind':match[0]})
    return {'root':str(root),'qmlFiles':count,'findings':findings,'proceduralOrSvgArtwork':artwork}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('roots',nargs='+',type=Path)
    parser.add_argument('--inventory',action='store_true')
    args=parser.parse_args()
    map_file=Path(__file__).resolve().parents[2]/'shared/Icons/IconMap.js'
    known=set(re.findall(r'^  "([^"]+)":',map_file.read_text(),re.M))
    reports=[inspect(root,known) for root in args.roots]
    if not args.inventory:
        for report in reports: report['proceduralOrSvgArtworkCount']=len(report.pop('proceduralOrSvgArtwork'))
    print(json.dumps(reports,ensure_ascii=False,indent=2))
    raise SystemExit(any(report['findings'] for report in reports))
if __name__=='__main__': main()

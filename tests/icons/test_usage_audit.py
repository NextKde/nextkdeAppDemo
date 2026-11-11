"""VM-only regression for literal and dynamic icon coverage scanning."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
SPEC=importlib.util.spec_from_file_location('audit_usage',ROOT/'tools/icons/audit_usage.py')
AUDIT=importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)

class UsageAudit(unittest.TestCase):
    def findings(self, qml):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);(root/'qml').mkdir()
            (root/'qml/View.qml').write_text('import QtQuick\n'+qml)
            return AUDIT.inspect(root,{'checkmark','star_fill','star','minus','plus','xmark'})['findings']
    def test_custom_buttons_and_conditionals_are_covered(self):
        rows=self.findings('Item { MusicActionButton { text: selected ? "−" : "+" }\n Text { text: flagged ? "★" : "" } }')
        self.assertEqual(len(rows),2)
    def test_dynamic_text_glyph_is_not_hidden_by_model(self):
        self.assertEqual(len(self.findings('Text { text: modelData.icon || "" }')),1)
    def test_conditions_and_accessible_names_are_not_icon_names(self):
        self.assertEqual(self.findings('Symbols.Icon { name: action === "delete" ? "xmark" : "plus"; Accessible.name: "Delete entry" }'),[])
    def test_unknown_returned_name_is_reported(self):
        self.assertIn('missing_symbol',self.findings('Symbols.Icon { name: selected ? "checkmark" : "missing_symbol" }')[0]['reason'])
    def test_content_item_and_path_text_are_not_glyph_fallbacks(self):
        self.assertEqual(self.findings('Item { ToolButton { text: "×"; contentItem: Symbols.Icon { name: "xmark" } }\n Text { text: entry.path.split("/").join(" › ") } }'),[])

if __name__=='__main__':unittest.main()

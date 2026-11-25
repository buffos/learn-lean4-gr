"""Ενημερώνει imports/includes μιας ενότητας από τα αρχεία M*.lean που υπάρχουν.
Χρήση: python tools/sync_chapter.py E01"""
import re, sys, pathlib
ch = sys.argv[1]
p = pathlib.Path(f'Mathimata/{ch}.lean')
mods = sorted(f.stem for f in pathlib.Path(f'Mathimata/{ch}').glob('M*.lean'))
s = p.read_text(encoding='utf-8')
s = re.sub(rf'import Mathimata\.{ch}\.M\d+\n', '', s)
s = re.sub(rf'\n\{{include 2 Mathimata\.{ch}\.M\d+\}}\n', '\n', s)
s = s.replace('import Mathimata.Meta\n', 'import Mathimata.Meta\n' + ''.join(f'import Mathimata.{ch}.{m}\n' for m in mods), 1)
s = s.rstrip('\n') + '\n' + ''.join(f'\n{{include 2 Mathimata.{ch}.{m}}}\n' for m in mods)
p.write_text(s, encoding='utf-8', newline='\n')
print(ch, mods)

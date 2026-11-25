"""Ρυθμίζει τον αριθμό των ':' στα εμφωλευμένα Verso directives.
Γράφουμε πάντα ':::' και το script δίνει στο εξωτερικό περισσότερα.
Χρήση: python tools/fix_colons.py Mathimata/**/*.lean"""
import re, sys

def fix(text):
    lines = text.split('\n')
    stack, nodes, in_code = [], [], False
    for i, l in enumerate(lines):
        s = l.strip()
        if s.startswith('```'):
            in_code = not in_code
            continue
        if in_code:
            continue
        m = re.match(r'^(:{3,})(\S.*)?$', l)
        if not m:
            continue
        if m.group(2):  # άνοιγμα
            node = {'open': i, 'close': None, 'h': 0, 'kids': []}
            if stack:
                stack[-1]['kids'].append(node)
            nodes.append(node)
            stack.append(node)
        elif stack:
            stack.pop()['close'] = i
    def height(n):
        n['h'] = 1 + max((height(k) for k in n['kids']), default=0)
        return n['h']
    for n in nodes:
        if n['h'] == 0:
            height(n)
    for n in nodes:
        c = ':' * (2 + n['h'])
        lines[n['open']] = re.sub(r'^:{3,}', c, lines[n['open']])
        if n['close'] is not None:
            lines[n['close']] = c
    return '\n'.join(lines)

for p in sys.argv[1:]:
    t = open(p, encoding='utf-8').read()
    t = t.replace('(error := true)', '+error')
    t = t.replace('(severity := error)', '(severity := Lean.MessageSeverity.error)')
    open(p, 'w', encoding='utf-8', newline='\n').write(fix(t))
    print('ok', p)

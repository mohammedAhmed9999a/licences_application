import pathlib
import re

root = pathlib.Path('lib')
combined_pattern = re.compile(r'(\d+)\.(sp|w|h|r)(\d+)\.(\2)')
ext_re = re.compile(r'\.(sp|w|h|r)\b')
files_fixed = 0

for path in sorted(root.rglob('*.dart')):
    text = path.read_text(encoding='utf-8')
    original = text

    # Repair malformed ScreenUtil chains like 1.sp6.sp, 2.w6.w, 30.w0.w
    text = combined_pattern.sub(lambda m: f'{m.group(1)}{m.group(3)}.{m.group(2)}', text)

    lines = text.splitlines(True)
    out_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if 'const ' in line:
            if ext_re.search(line):
                line = line.replace('const ', '', 1)
            else:
                block = line
                depth = line.count('(') - line.count(')')
                j = i + 1
                while j < len(lines) and depth > 0:
                    block += lines[j]
                    depth += lines[j].count('(') - lines[j].count(')')
                    j += 1
                if ext_re.search(block):
                    line = line.replace('const ', '', 1)
        out_lines.append(line)
        i += 1

    text = ''.join(out_lines)

    if text != original:
        path.write_text(text, encoding='utf-8')
        files_fixed += 1

print(f'Fixed {files_fixed} files')

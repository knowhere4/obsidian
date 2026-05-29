import sys
from pathlib import Path

file_path = Path(sys.argv[1])
content = file_path.read_text(encoding='utf-8')

if content.startswith('---'):
    end = content.find('---', 3)
    if end != -1:
        frontmatter = content[3:end]
        if 'publish:' not in frontmatter:
            new_content = '---' + frontmatter + 'publish: true\n---' + content[end+3:]
            file_path.write_text(new_content, encoding='utf-8')
            print("publish: true 추가됨")
        else:
            print("이미 publish 설정 있음")
else:
    new_content = '---\npublish: true\n---\n\n' + content
    file_path.write_text(new_content, encoding='utf-8')
    print("publish: true 추가됨")

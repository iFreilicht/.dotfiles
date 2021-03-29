#!/usr/bin/env python3
with open('/usr/lib/code/product.json', 'r+') as f:
    old_content = f.read()
    new_content = old_content.replace(
        '''"extensionsGallery": {
\t\t"serviceUrl": "https://open-vsx.org/vscode/gallery",
\t\t"itemUrl": "https://open-vsx.org/vscode/item"''',
        '''"extensionsGallery": {
\t\t"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
\t\t"cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
\t\t"itemUrl": "https://marketplace.visualstudio.com/items"''')

    f.seek(0)
    f.write(new_content)

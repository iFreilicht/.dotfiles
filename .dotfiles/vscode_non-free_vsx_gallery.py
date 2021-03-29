#!/usr/bin/env python3
"""Small script to make Code - OSS use the microsoft vsx gallery.
See https://stackoverflow.com/a/64537579/2533467
"""

PRODUCT_JSON = '/usr/lib/code/product.json'

OLD_GALLERY = '''"extensionsGallery": {
\t\t"serviceUrl": "https://open-vsx.org/vscode/gallery",
\t\t"itemUrl": "https://open-vsx.org/vscode/item"'''

NEW_GALLERY = '''"extensionsGallery": {
\t\t"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
\t\t"cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
\t\t"itemUrl": "https://marketplace.visualstudio.com/items"'''

with open(PRODUCT_JSON, 'r+') as f:
    old_content = f.read()
    if NEW_GALLERY in old_content:
        print("Already using Microsoft gallery.")
        exit(0)
    if not OLD_GALLERY in old_content:
        print(f"Couldn't find open-vsx gallery in {PRODUCT_JSON}!")
        exit(1)

    new_content = old_content.replace(OLD_GALLERY, NEW_GALLERY)

    f.seek(0)
    f.write(new_content)
    print(f"Successfully replaced gallery in {PRODUCT_JSON}.")

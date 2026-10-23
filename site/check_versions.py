"""Check real pre-rendered version links and their hydration route inventory."""
import json
import sys
from html.parser import HTMLParser
from pathlib import Path


class Page(HTMLParser):
    def __init__(self, path):
        super().__init__()
        self.anchors = []
        self.current = None
        self.data = None
        self.feed(path.read_text())

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a':
            self.current = dict(href=attrs.get('href'), classes=attrs.get('class', '').split(), text='')
        if tag == 'meta' and attrs.get('name') == 'ms-data':
            self.data = json.loads(attrs['content'])

    def handle_data(self, data):
        if self.current is not None:
            self.current['text'] += data

    def handle_endtag(self, tag):
        if tag == 'a' and self.current is not None:
            self.anchors.append(self.current)
            self.current = None


def check(root):
    cases = 0
    for channel, base, directory in [('release', '/moonspec/', root), ('next', '/moonspec/next/', root / 'next')]:
        for slug in [f'version-check-{channel}-only', 'version-check-shared']:
            page = Page(directory / 'docs' / slug / 'index.html')
            shared = slug == 'version-check-shared'
            hrefs = ['/moonspec/' + (f'docs/{slug}/' if shared or channel == 'release' else ''),
                     '/moonspec/next/' + (f'docs/{slug}/' if shared or channel == 'next' else '')]
            versions = [a for a in page.anchors if 'ms-version-link' in a['classes']]
            assert [a['href'] for a in versions] == hrefs, (channel, slug, versions, hrefs)
            assert ['ms-version-current' in a['classes'] for a in versions] == [channel == 'release', channel == 'next']
            banners = [a for a in page.anchors if a['text'].startswith('Go to the ') and a['text'].endswith(' docs.')]
            assert [a['href'] for a in banners] == ([hrefs[0]] if channel == 'next' else []), banners
            assert page.data is not None, 'missing hydration data'
            assert (page.data['route'] in page.data['counterpart_routes']) == shared, page.data
            assert any(p['route'] == page.data['route'] for p in page.data['pages'])
            cases += 1
    print(f'version links: {cases} real pages verified, including asymmetric routes and hydration data')


if __name__ == '__main__':
    check(Path(sys.argv[1]))

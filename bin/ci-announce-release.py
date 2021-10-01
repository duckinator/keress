#!/usr/bin/env python3

from os import environ
from pathlib import Path
from pprint import pprint
import json
import urllib.error
import urllib.request
import sys


BASE_URL = 'https://github.com/duckinator/keress'


def fetch(method, url, data=None):
    data = json.dumps(data).encode()
    method = method.upper()
    request = urllib.request.Request(url, data=data, method=method)
    request.add_header('Content-Type', 'application/json')
    request.add_header('User-Agent', 'keress-announce-release/1.0 (+https://github.com/duckinator/keress/blob/main/bin/ci-announce-release.py')
    with urllib.request.urlopen(request) as response:
        return response


def request_body():
    if environ.get('CIRRUS_PR', None):
        url = f"{BASE_URL}/pull/{environ['CIRRUS_PR']}"
    else:
        url = f"{BASE_URL}/tree/{environ['CIRRUS_CHANGE_IN_REPO'][0:7]}"

    version = Path('src/version.txt').read_text().strip()
    embed = {
        'title': f'Keress v{version}',
        'description':
            f"""{environ['CIRRUS_CHANGE_MESSAGE'].strip()}

            {url}""",

    }

    return {'embeds': [embed]}


def main(argv):
    try:
        url = environ['DISCORD_WEBHOOK']
        fetch('post', url, request_body())
    except urllib.error.HTTPError as e:
        pprint(e)
        pprint(e.headers.as_string())
        pprint(e.reason)


main(sys.argv)

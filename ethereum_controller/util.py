"""Chain Utils"""

ETHEREUM = 'eth'
POLYGON = 'poly'


def word2chain(word: str):
    if word == 'e':
        return ETHEREUM
    elif word == 'p':
        return POLYGON
    else:
        raise RuntimeError('Invalid Chain Word.')
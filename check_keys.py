import json

with open('assets/translations/en.json') as f:
    en = json.load(f)
with open('assets/translations/ta.json') as f:
    ta = json.load(f)
with open('assets/translations/si.json') as f:
    si = json.load(f)

en_keys = set(en.keys())
ta_keys = set(ta.keys())
si_keys = set(si.keys())

print(f'en.json: {len(en_keys)} keys')
print(f'ta.json: {len(ta_keys)} keys')
print(f'si.json: {len(si_keys)} keys')
print()

missing_ta = en_keys - ta_keys
missing_si = en_keys - si_keys

if missing_ta:
    print(f'MISSING in ta.json ({len(missing_ta)}):')
    for k in sorted(missing_ta):
        print(f'  - {k}')
else:
    print('ta.json has ALL en.json keys')

if missing_si:
    print(f'MISSING in si.json ({len(missing_si)}):')
    for k in sorted(missing_si):
        print(f'  - {k}')
else:
    print('si.json has ALL en.json keys')

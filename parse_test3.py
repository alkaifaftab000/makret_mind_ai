import json
with open('api_res.json') as f:
    products = json.load(f)
for p in products:
    print(f"Product: {p.get('name')}")
    print(f"  Videos: {len(p.get('videos', []))}")
    print(f"  Posters: {len(p.get('posters', []))}")
    print(f"  StudioImages: {len(p.get('studioImages', []))}")

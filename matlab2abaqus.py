# -*- coding: mbcs -*-
# author: hyc
#email:202437682@mail.sdu.edu.cn


import math
import ast

# === File path =======
file_path1 = r'G:\hycplugin\easy_voronoi_github\grain_boundary_poly.txt'
# =============================================================

# === Flattening parameter =======
# Compression ratio in the y direction:
# for example, 2.0 means all y-coordinates are divided by 2
# A larger value results in flatter grains
y_shrink_ratio = 1
# =============================================================


# ------------------- Geometry utilities -------------------
def point_in_poly(x, y, poly):
    n = len(poly)
    if n < 3:
        return False
    inside = False
    x0, y0 = poly[0]
    for i in range(1, n + 1):
        x1, y1 = poly[i % n]
        if ((y0 > y) != (y1 > y)):
            xinters = (x1 - x0) * (y - y0) / (y1 - y0 + 1e-30) + x0
            if x < xinters:
                inside = not inside
        x0, y0 = x1, y1
    return inside


def poly_bbox(poly):
    xs = [p[0] for p in poly]
    ys = [p[1] for p in poly]
    return (min(xs), max(xs), min(ys), max(ys))


# ------------------- y-direction compression transform -------------------
def transform_y(x, y, ratio):
    return x, y / ratio


def transform_segments_y(segments, ratio):
    new_segments = []
    for (p1, p2) in segments:
        x1, y1 = transform_y(p1[0], p1[1], ratio)
        x2, y2 = transform_y(p2[0], p2[1], ratio)
        new_segments.append(((x1, y1), (x2, y2)))
    return new_segments


def transform_polygons_y(polygons, ratio):
    new_polygons = []
    for poly in polygons:
        new_poly = []
        for (x, y) in poly:
            xx, yy = transform_y(x, y, ratio)
            new_poly.append((xx, yy))
        new_polygons.append(new_poly)
    return new_polygons


# ------------------- Read txt file: compatible with segments / polygons -------------------
def read_voronoi_or_gb_file(path):
    with open(path, 'r') as f:
        raw_lines = f.readlines()

    # Remove empty lines
    lines = []
    for ln in raw_lines:
        s = ln.strip()
        if s:
            lines.append(s)

    if not lines:
        raise RuntimeError("Empty file: %s" % path)

    length = None
    width = None
    thickness = None
    start_idx = 0

    # Try to read len and wid from the first line
    toks0 = lines[0].split()
    if len(toks0) == 2:
        try:
            length = float(toks0[0])
            width = float(toks0[1])
            start_idx = 1
        except:
            length = None
            width = None
            start_idx = 0

    # Try to read thickness from the second line, which contains only one value
    if start_idx == 1 and len(lines) >= 2:
        toks1 = lines[1].split()
        if len(toks1) == 1:
            try:
                thickness = float(toks1[0])
                start_idx = 2
            except:
                thickness = None
                start_idx = 1

    segments = []
    polygons = []
    cur_poly = []

    # Python 2 does not support nonlocal, so only the list content is modified here
    def flush_poly():
        if len(cur_poly) >= 3:
            if (abs(cur_poly[0][0] - cur_poly[-1][0]) < 1e-12 and
                abs(cur_poly[0][1] - cur_poly[-1][1]) < 1e-12):
                cur_poly.pop()
            if len(cur_poly) >= 3:
                polygons.append(list(cur_poly))
        del cur_poly[:]

    for s in lines[start_idx:]:
        ss = s.strip()
        low = ss.lower()

        # 1) Polygon mode with NaN-separated segments
        if ('nan' in low):
            flush_poly()
            continue

        # 2) Segment format: ((x1,y1),(x2,y2))
        if ss.startswith("((") or ss.startswith("[("):
            try:
                pair = ast.literal_eval(ss)
                x1, y1 = float(pair[0][0]), float(pair[0][1])
                x2, y2 = float(pair[1][0]), float(pair[1][1])
                segments.append(((x1, y1), (x2, y2)))
            except:
                pass
            continue

        # 3) Numeric format: either x y or x1 y1 x2 y2
        toks = ss.replace(',', ' ').split()
        if len(toks) == 2:
            try:
                x = float(toks[0])
                y = float(toks[1])
                cur_poly.append((x, y))
            except:
                pass
        elif len(toks) >= 4:
            try:
                x1 = float(toks[0])
                y1 = float(toks[1])
                x2 = float(toks[2])
                y2 = float(toks[3])
                segments.append(((x1, y1), (x2, y2)))
            except:
                pass

    # Flush remaining polygon at the end of the file
    flush_poly()

    # If polygon mode is used, convert polygons into line segments for sketching
    if len(polygons) > 0:
        seg2 = []
        for poly in polygons:
            n = len(poly)
            for i in range(n):
                p1 = poly[i]
                p2 = poly[(i + 1) % n]
                seg2.append((p1, p2))
        segments = seg2

    # If length/width are missing, estimate the bounding box from the data as a fallback
    if length is None or width is None:
        xs = []
        ys = []
        for (p1, p2) in segments:
            xs.extend([p1[0], p2[0]])
            ys.extend([p1[1], p2[1]])
        if xs and ys:
            length = max(xs)
            width = max(ys)
        else:
            length = 1.0
            width = 1.0

    return length, width, thickness, segments, polygons


# ===================== Read data =====================
length, width, tGB, segs, polys = read_voronoi_or_gb_file(file_path1)

print("Original data loaded: len=%.6g, wid=%.6g, thickness=%s, segments=%d, polygons=%d"
      % (length, width, str(tGB), len(segs), len(polys)))

# ===================== Apply y-direction flattening =====================
if y_shrink_ratio <= 0.0:
    raise RuntimeError("y_shrink_ratio must be > 0")

segs = transform_segments_y(segs, y_shrink_ratio)
polys = transform_polygons_y(polys, y_shrink_ratio)
width = width / y_shrink_ratio

print("After y-direction compression: len=%.6g, wid=%.6g, y_shrink_ratio=%.6g"
      % (length, width, y_shrink_ratio))


# ===================== Abaqus modeling =====================
from abaqus import *
from abaqusConstants import *
from caeModules import *
from driverUtils import executeOnCaeStartup

executeOnCaeStartup()

Mdb()
myModel = mdb.models['Model-1']

# 1) Sketch the outer frame
s = myModel.ConstrainedSketch(name='__profile__', sheetSize=200.0)
s.setPrimaryObject(option=STANDALONE)
s.rectangle(point1=(0.0, 0.0), point2=(length, width))

# 2) Create a 2D shell part
p = myModel.Part(name='Part-1', dimensionality=TWO_D_PLANAR, type=DEFORMABLE_BODY)
p.BaseShell(sketch=s)
s.unsetPrimaryObject()
del myModel.sketches['__profile__']

session.viewports['Viewport: 1'].setValues(displayedObject=p)

# 3) Create an overlay sketch for partitioning
fcs = p.faces
t = p.MakeSketchTransform(sketchPlane=fcs[0], sketchPlaneSide=SIDE1,
                          origin=(0.0, 0.0, 0.0))
s1 = myModel.ConstrainedSketch(name='__partition__',
                               sheetSize=max(length, width) * 2.0,
                               transform=t)
s1.setPrimaryObject(option=SUPERIMPOSE)
p.projectReferencesOntoSketch(sketch=s1, filter=COPLANAR_EDGES)

# 4) Draw the flattened grain-boundary line segments
for (p1, p2) in segs:
    s1.Line(point1=(p1[0], p1[1]), point2=(p2[0], p2[1]))

# 5) Execute face partition
pickedFaces = fcs.getSequenceFromMask(mask=('[#1 ]', ), )
p.PartitionFaceBySketch(faces=pickedFaces, sketch=s1)

s1.unsetPrimaryObject()
del myModel.sketches['__partition__']
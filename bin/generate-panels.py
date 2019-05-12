#!/usr/bin/python3

import operator
import os

from PIL import Image, ImageDraw

wall1 = "#9aabc5" # light
wall2 = "#334358" # dark
floor = "#e8e8e8"
border = "#8e8e8e"

segment_size = (1024, 1024)

def tprod(a, b):
    return tuple(map(operator.mul, a, b))

def image_size(h_segments, v_segments):
    return tprod(segment_size, (h_segments, v_segments))

# Generates a texture for a cube with one face for top/bottom and another
# for all sides.
def cube_horiz_vert(horiz_color, vert_color, border_color=border):
    img = Image.new('RGB', image_size(3, 2))

    horiz_face = face(horiz_color, border_color)
    vert_face = face(vert_color, border_color)

    for row in range(0, 2):
        for col in range(0, 3):
            cur_face = vert_face
            if row == 0 and col in [0, 2]: # top/bottom faces
                cur_face = horiz_face
            img.paste(cur_face, tprod(segment_size, (col, row)))

    return img

def face(color, border_color=None):
    img = Image.new('RGB', image_size(1, 1))
    draw = ImageDraw.Draw(img)
    draw.rectangle([(0, 0), segment_size], fill=color)
    if border_color is not None:
        draw.rectangle([(0, 0), (1024, 8)], fill=border_color) # top border
        draw.rectangle([(0, 1024 - 8), (1024, 1024)], fill=border_color) # bottom border
        draw.rectangle([(0, 0), (8, 1024)], fill=border_color) # left border
        draw.rectangle([(1024 - 8, 0), (1024, 1024)], fill=border_color) # right border
    return img

os.chdir("src/textures")

cube_horiz_vert(horiz_color=floor, vert_color=wall2).save('generic-panel-01-03-transition.png')
face(floor, border).save('generic-panel-01.png')
face(wall1, border).save('generic-panel-02.png')
face(wall2, border).save('generic-panel-03.png')

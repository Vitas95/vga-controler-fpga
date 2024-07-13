"""
This script creates a file with an 8x8-bit font memory for the FPGA.
The font reads from the .ttf file. The way the script processes the 
font is quite strange. First of all, pygame draws the image with all 
the font symbols. In the next step, the image is read symbol by symbol 
with a 1-bit resolution. Font data is saved in the .txt file in binary 
form, line by line, 8 bits in line 8 lines per symbol.
"""

import pygame
import cv2


def EightBitsToNBits(channel, N):
    return round((channel * ((2**N) - 1)) / 255.0)


font_dir = "Mx437_IBM_EGA_8x8.ttf"  # Path to the font file
pygame.font.init()
pygfont = pygame.font.Font(font_dir, 8)  # Open font with 8 bit size

# Create symbols to display
symbols = ""
for i in range(127):
    symbols = symbols + chr(i + 1)

# Create font image and save it
surf = pygfont.render(symbols, False, (255, 255, 255), (0, 0, 0))
pygame.image.save(surf, "FontImage.jpg")

# Open the image
img = cv2.imread("FontImage.jpg", cv2.IMREAD_GRAYSCALE)

# Write all zeros for the first symbol
symbols_data = ""
for i in range(8):
    symbols_data = symbols_data + "00000000" + "\n"

# Save the data
for k in range(127):
    for i in range(8):
        for j in range(8):
            symbols_data = symbols_data + str(EightBitsToNBits(img[i][j + k * 8], 1))
        symbols_data = symbols_data + "\n"

# Write memory txt file
with open("FontMemoryFile.txt", "w+") as f:
    f.write(symbols_data[:-1])
    f.close()

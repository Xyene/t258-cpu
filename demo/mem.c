vga_base = 0x9000;
white = 0xffffff;
width = 160;
height = 120;

for (x = 0; x < width; x++) {
    for (y = 0; y < height; y++) {
        [vga_base + y * width + x] = white;
    }
}
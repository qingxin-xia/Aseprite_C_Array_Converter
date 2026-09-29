# Aseprite_C_Array_Converter
Lua script to convert Aseprite animations with an indexed color palette into a C array for embedded systems

## Array Format & Use Cases:

* Both .c and .h files are created in the same folder as the Aseprite animation
* Palette is converted into RGB565 values (16 bit) for compatibility in libraries like Adafruit GFX
* The duration of each frame is stored in a separate array in milliseconds
* The main pixel data of the animation is 2D: \[FrameNum\]\[FrameHeight * FrameWidth\]
* Each frame is stored as a continuous 1D array to allow for data streaming in embedded systems
* To save space, each pixel is represented as the index corresponding to the palette and stored in uint8_t (8 bit) 
  * This format is compatible with palette sizes <= 255
  * During runtime, the pixel color is referenced by palette\[frame\]\[row * rowLen + col\]

## How to Use:

* Open Aseprite and go to File>Scripts>Open Scripts Folder
* Upload the script to the folder and click File>Scripts>Rescan Scripts Folder
* Save your Aseprite animation file first
* Check that your file is in indexed mode (Sprite>Color Mode>Indexed) and has <= 255 colors
  * If your file uses colors with alpha (transparent), switch to RGB color mode, click on menu above palette, select New Palette From Sprite, and switch back to indexed mode 
* To run the script on the current animation, click File>Scripts>cArrayConverter and allow permissions

## Examples:
* Example embedded project using the array results from this script: [Tamagotchi Book Nook](https://github.com/qingxin-xia/Tamagotchi_Book_Nook)



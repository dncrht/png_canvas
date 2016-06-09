# png_canvas

A pure Ruby reimplementation of Rui Carmo's [pngcanvas](https://github.com/rcarmo/pngcanvas) Python library, featuring text writing and few renames.


## Usage

Just add it in your Gemfile:

```ruby
gem 'png_canvas'
```

and require it when needed:

```ruby
require 'png_canvas'
```

### Rendering an image

You can render the [reference image](https://github.com/rcarmo/pngcanvas/blob/master/reference.png) with:

```ruby
png = PngCanvas.new(512, 512)
png.rectangle(0, 0, 512 - 1, 512 - 1)

png.vertical_gradient(1, 1, 512 - 2, 512 - 2, [0xff, 0, 0, 0xff], [0x20, 0, 0xff, 0x80])

png.color = [0, 0, 0, 0xff]
png.line(0, 0, 512 - 1, 512 - 1)
png.line(0, 0, 512 / 2, 512 - 1)
png.line(0, 0, 512 - 1, 512 / 2)

png.copy_rectangle(1, 1, 512 / 2 - 1, 512 / 2 - 1, 1, 512 / 2, png)

png.blend_rectangle(1, 1, 512 / 2 - 1, 512 / 2 - 1, 512 / 2, 0, png)
png.save 'reference.png'
```

## Reference

- Constructor parameters: **width, height, bgcolor: _default bgcolor_, color: _default fgcolor_**

Colors are specified as 4 element arrays, each representing red, green, blue and alpha values ranging from 0 to 255.

Default background color is white: [0xff, 0xff, 0xff, 0xff]

Default foreground color is black: [0x00, 0x00, 0x00, 0xff]

### Public instance methods

- **color(color)**: sets the default foreground color for the following points and lines
- **point(x, y, color = nil)**: draws a point at x, y using the specified color (if any) or default
- **text(x0, y0, string, color = nil)**: writes the string of text at x0, y0
- **line(x0, y0, x1, y1)**: draws a single line using default color
- **polyline(point_array)**: draws lines using default color
- **vertical_gradient(x0, y0, x1, y1, from_color, to_color)**: draws a rectangular color gradient from from_color to to_color
- **rectangle(x0, y0, x1, y1)**: draws a rectangle with default color
- **filled_rectangle(x0, y0, x1, y1)**: draws a filled rectangle with default color
- **copy_rectangle(x0, y0, x1, y1, dx, dy, destination_png)**: copies rectangle from destination_png to current canvas with dx, dy offset
- **blend_rectangle(x0, y0, x1, y1, dx, dy, destination_png, alpha = 0xff)**: copies rectangle from destination_png to current canvas using alpha transparency
- **save(file_path)**: saves the canvas to the file_path
- **load(file_path)**: loads the PNG file from the file_path for manipulation
- **dump**: returns the contents of the canvas as binary

## Contribute

- Fork it
- Write your feature with a test
- Issue a pull request
- …
- Profit!

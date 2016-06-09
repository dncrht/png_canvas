# Based on Rui Carmo's PNGCanvas
# https://taoofmac.com/space/projects/PNGCanvas
# https://github.com/rcarmo/pngcanvas
# Reference: http://apidock.com/ruby/Array/pack

require 'zlib'

class PngCanvas

  VERSION = '0.0.1'

  CHARSET = {
    '0' => [0b01111000, 0b10000100, 0b01111000],
    '1' => [0b01000100, 0b11111100, 0b00000100],
    '2' => [0b01000100, 0b10001100, 0b10010100, 0b01100100],
    '3' => [0b01001000, 0b10000100, 0b10100100, 0b01011000],
    '4' => [0b00110000, 0b01010000, 0b11111100, 0b00010000],
    '5' => [0b11101000, 0b10100100, 0b10100100, 0b10011000],
    '6' => [0b01111000, 0b10010100, 0b10100100, 0b00011000],
    '7' => [0b10000000, 0b10001100, 0b10110000, 0b11000000],
    '8' => [0b01011000, 0b10100100, 0b10100100, 0b01011000],
    '9' => [0b01100000, 0b10010100, 0b10100100, 0b01111000],
    'A' => [0b01111100, 0b10010000, 0b10010000, 0b01111100],
    'B' => [0b11111100, 0b10100100, 0b10100100, 0b01011000],
    'C' => [0b01111000, 0b10000100, 0b10000100, 0b01001000],
    'D' => [0b11111100, 0b10000100, 0b10000100, 0b01111000],
    'E' => [0b11111100, 0b10100100, 0b10100100, 0b10000100],
    'F' => [0b11111100, 0b10100000, 0b10100000, 0b10000000],
    'G' => [0b01111000, 0b10000100, 0b10010100, 0b01011100],
    'H' => [0b11111100, 0b00100000, 0b00100000, 0b11111100],
    'I' => [0b10000100, 0b11111100, 0b10000100],
    'J' => [0b00001000, 0b00000100, 0b10000100, 0b11111000],
    'K' => [0b11111100, 0b00100000, 0b01011000, 0b10000100],
    'L' => [0b11111100, 0b00000100, 0b00000100, 0b00000100],
    'M' => [0b11111100, 0b01100000, 0b01100000, 0b11111100],
    'N' => [0b11111100, 0b01100000, 0b00111000, 0b11111100],
    'O' => [0b01111000, 0b10000100, 0b10000100, 0b01111000],
    'P' => [0b11111100, 0b10010000, 0b10010000, 0b01100000],
    'Q' => [0b01111000, 0b10010100, 0b10001100, 0b01111000],
    'R' => [0b11111100, 0b10010000, 0b10011000, 0b11100100],
    'S' => [0b01100100, 0b10010100, 0b10010100, 0b10001000],
    'T' => [0b10000000, 0b10000000, 0b11111100, 0b10000000, 0b10000000],
    'U' => [0b11111000, 0b00000100, 0b00000100, 0b11111000],
    'V' => [0b11110000, 0b00001100, 0b00001100, 0b11110000],
    'W' => [0b11111100, 0b00011000, 0b00011000, 0b11111100],
    'X' => [0b11001100, 0b00110000, 0b00110000, 0b11001100],
    'Y' => [0b11000000, 0b00100000, 0b00011100, 0b00100000, 0b11000000],
    'Z' => [0b10001100, 0b10010100, 0b10100100, 0b11000100],
    'a' => [0b00011000, 0b00100100, 0b00101000, 0b00111100],
    'b' => [0b11111100, 0b00100100, 0b00100100, 0b00011000],
    'c' => [0b00011000, 0b00100100, 0b00100100, 0b00100100],
    'd' => [0b00011000, 0b00100100, 0b00101000, 0b11111100],
    'e' => [0b00011000, 0b00101100, 0b00110100, 0b00010100],
    'f' => [0b00010000, 0b01111100, 0b10010000, 0b01000000],
    'g' => [0b00010000, 0b00101010, 0b00101010, 0b00111100],
    'h' => [0b11111100, 0b00100000, 0b00100000, 0b00011100],
    'i' => [0b00100100, 0b10111100, 0b00000100],
    'j' => [0b00000100, 0b00000010, 0b10111100],
    'k' => [0b11111100, 0b00010000, 0b00010000, 0b00101100],
    'l' => [0b10000100, 0b11111100, 0b00000100],
    'm' => [0b00111100, 0b00100000, 0b00011000, 0b00100000, 0b00111100],
    'n' => [0b00111100, 0b00010000, 0b00100000, 0b00011100],
    'o' => [0b00011000, 0b00100100, 0b00100100, 0b00011000],
    'p' => [0b00111110, 0b00101000, 0b00101000, 0b00010000],
    'q' => [0b00010000, 0b00101000, 0b00101000, 0b00111110],
    'r' => [0b00111100, 0b00010000, 0b00100000, 0b00010000],
    's' => [0b00010100, 0b00110100, 0b00101100, 0b00101000],
    't' => [0b00100000, 0b11111000, 0b00100100, 0b00001000],
    'u' => [0b00111000, 0b00000100, 0b00001000, 0b00111100],
    'v' => [0b00111000, 0b00000100, 0b00111000],
    'w' => [0b00111000, 0b00000100, 0b00011100, 0b00000100, 0b00111000],
    'x' => [0b00100100, 0b00011000, 0b00011000, 0b00100100],
    'y' => [0b00110000, 0b00001010, 0b00001010, 0b00111100],
    'z' => [0b00100100, 0b00101100, 0b00110100, 0b00100100],
    '.' => [0b00001100, 0b00001100, 0b00000000],
    ',' => [0b00001101, 0b00001110, 0b00000000],
    ':' => [0b01101100, 0b01101100]
  }

  attr_accessor :color, :canvas

  def initialize(width, height, bgcolor: [0xff, 0xff, 0xff, 0xff], color: [0, 0, 0, 0xff])
    @canvas = []
    @width = width
    @height = height
    @color = color
    height.times { @canvas << [bgcolor] * width }
  end

  def point(x, y, color = nil)
    return if x < 0 || y < 0 || x > (@width - 1) || y > (@height - 1)
    color = @color if color.nil?
    @canvas[y][x] = blend(@canvas[y][x], color)
  end

  def text(x0, y0, string, color = nil)
    string = string.to_s
    return if string.empty?
    x = 0
    string.each_char do |char|
      x += character(x + x0, y0, char, color)
    end
  end

  def vertical_gradient(x0, y0, x1, y1, from_color, to_color)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    gradient = gradient_list(from_color, to_color, y1 - y0)
    (x0..x1).each do |x|
      (y0..y1).each do |y|
        point(x, y, gradient[y - y0])
      end
    end
  end

  def rectangle(x0, y0, x1, y1)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    polyline([[x0, y0], [x1, y0], [x1, y1], [x0, y1], [x0, y0]])
  end

  def filled_rectangle(x0, y0, x1, y1)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    (x0..x1).each do |x|
      (y0..y1).each do |y|
        point(x, y, @color)
      end
    end
  end

  def copy_rectangle(x0, y0, x1, y1, dx, dy, destination_png)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    (x0..x1).each do |x|
      (y0..y1).each do |y|
        destination_png.canvas[dy + y - y0][dx + x - x0] = @canvas[y][x]
      end
    end
  end

  def blend_rectangle(x0, y0, x1, y1, dx, dy, destination_png, alpha = 0xff)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    (x0..x1).each do |x|
      (y0..y1).each do |y|
        rgba = @canvas[y][x] + [alpha]
        destination_png.point(dx + x - x0, dy + y - y0, rgba)
      end
    end
  end

  # Draw a line using Xiaolin Wu's antialiasing technique
  def line(x0, y0, x1, y1)
    # clean params
    x0, y0, x1, y1 = x0.to_i, y0.to_i, x1.to_i, y1.to_i
    if y0 > y1
      y0, y1, x0, x1 = y1, y0, x1, x0
    end
    dx = x1 - x0
    if dx < 0
      sx = -1
    else
      sx = 1
    end
    dx *= sx
    dy = y1 - y0

    # 'easy' cases
    if dy == 0
      if sx > 0
        ordering = :each
      else
        ordering = :reverse_each
        x0, x1 = x1, x0
      end
      (x0..x1).send(ordering) { |x| point(x, y0) }
      return
    end
    if dx == 0
      (y0..y1).each { |y| point(x0, y) }
      point(x1, y1)
      return
    end
    if dx == dy
      if sx > 0
        ordering = :each
      else
        ordering = :reverse_each
        x0, x1 = x1, x0
      end
      (x0..x1).send(ordering) do |x|
        point(x, y0)
        y0 += 1
      end
      return
    end

    # main loop
    point(x0, y0)
    e_acc = 0
    if dy > dx # vertical displacement
      e = (dx << 16) / dy
      (y0..y1).each do |i|
        e_acc_temp, e_acc = e_acc, (e_acc + e) & 0xffff
        if e_acc <= e_acc_temp
          x0 += sx
        end
        w = 0xff - (e_acc >> 8)
        point(x0, y0, intensity(@color, w))
        y0 += 1
        point(x0 + sx, y0, intensity(@color, 0xff - w))
      end
      point(x1, y1)
      return
    end

    # horizontal displacement
    e = (dy << 16) / dx
    ordering = sx > 0 ? :each : :reverse_each
    (x0..x1 - sx).send(ordering) do |i|
      e_acc_temp, e_acc = e_acc, (e_acc + e) & 0xffff
      if e_acc <= e_acc_temp
        y0 += 1
      end
      w = 0xff - (e_acc >> 8)
      point(x0, y0, intensity(@color, w))
      x0 += sx
      point(x0, y0 + 1, intensity(@color, 0xff - w))
    end
    point(x1, y1)
  end

  def polyline(point_array)
    (point_array.size - 1).times do |i|
      line(
        point_array[i].first,
        point_array[i].last,
        point_array[i + 1].first,
        point_array[i + 1].last
      )
    end
  end

  def dump
    raw_list = []
    @height.times do |y|
      raw_list << 0.chr # filter type 0 (nil)
      @width.times do |x|
        raw_list << @canvas[y][x].pack('C3')
      end
    end
    raw_data = raw_list.join

    # 8-bit image represented as RGB tuples
    # simple transparency, alpha is pure white
    [137, 80, 78, 71, 13, 10, 26, 10].pack('C8') +
      pack_chunk('IHDR', [@width, @height, 8, 2, 0, 0, 0].pack('N2C5')) +
      pack_chunk('tRNS', [0xff, 0xff, 0xff, 0xff, 0xff, 0xff].pack('C6')) +
      pack_chunk('IDAT', Zlib::Deflate.deflate(raw_data, 9)) +
      pack_chunk('IEND', '')
  end

  def save(file_path)
    file = File.open file_path, 'wb'
    file.write dump
    file.close
  end

  def load(file_path)
    file = File.open file_path, 'rb'
    @canvas = []

    file.read(8) # load png header

    chunks(file) do |tag, data|
      if tag == 'IHDR'
        width, height, bitdepth, colortype, compression, filter, interlace = data.unpack('N2C5')
        @width = width
        @height = height
        if [bitdepth, colortype, compression, filter, interlace] != [8, 2, 0, 0, 0]
          raise 'Unsupported PNG format'
        end
      # we ignore tRNS because we use pure white as alpha anyway
      elsif tag == 'IDAT'
        raw_data = Zlib::Inflate.inflate(data)
        prev = nil
        i = 0
        @height.times do |y|
          filtertype = raw_data[i].ord
          i = i + 1
          cur = raw_data[i..i + @width * 3].unpack 'C*'
          rgb = defilter(cur, (y == 0 ?  nil : prev), filtertype)
          prev = cur
          i = i + @width * 3
          row = []
          j = 0
          @width.times do |x|
            pixel = rgb[j..j + 3]
            row << pixel
            j = j + 3
          end
          @canvas << row
        end
      end
    end
    file.close
  end

  private

  def pack_chunk(tag, data)
    to_check = tag + data
    [data.size].pack('N') + to_check + [Zlib.crc32(to_check)].pack('N')
  end

  def rectangle_helper(x0, y0, x1, y1)
    x0, y0, x1, y1 = x0.to_i, y0.to_i, x1.to_i, y1.to_i
    if x0 > x1
      x0, x1 = x1, x0
    end
    if y0 > y1
      y0, y1 = y1, y0
    end
    [x0, y0, x1, y1]
  end

  def defilter(cur, prev, filtertype, bpp = 3)
    if filtertype == 0 # No filter
      return cur
    elsif filtertype == 1 # Sub
      xp = 0
      [bpp..cur.size].each do |xc|
        cur[xc] = (cur[xc] + cur[xp]) % 256
        xp += 1
      end
    elsif filtertype == 2 # Up
      cur.size.times do |xc|
        cur[xc] = (cur[xc] + prev[xc]) % 256
      end
    elsif filtertype == 3 # Average
      xp = 0
      cur.size.times do |xc|
        cur[xc] = (cur[xc] + (cur[xp] + prev[xc]) / 2) % 256
        xp += 1
      end
    elsif filtertype == 4 # Paeth
      xp = 0
      bpp.times do |i|
        cur[i] = (cur[i] + prev[i]) % 256
      end
      [bpp..cur.size].each do |xc|
        a = cur[xp]
        b = prev[xc]
        c = prev[xp]
        p = a + b - c
        pa = (p - a).abs
        pb = (p - b).abs
        pc = (p - c).abs
        if pa <= pb && pa <= pc
          value = a
        elsif pb <= pc
          value = b
        else
          value = c
        end
        cur[xc] = (cur[xc] + value) % 256
        xp += 1
      end
    else
      raise 'Unrecognized scanline filter type'
    end
    cur
  end

  def chunks(f)
    until f.eof?
      length = f.read(4).unpack("N")[0]
      tag = f.read(4)
      data = f.read(length)

      crc = f.read(4).unpack("N")[0]
      raise 'File is corrupted' if Zlib.crc32(tag + data) != crc

      yield [tag, data]
    end
  end

  # Alpha-blends two colors, using the alpha given by c2
  def blend(c1, c2)
    3.times.map { |i| c1[i] * (0xff - c2[3]) + c2[i] * c2[3] >> 8 }
  end

  # Calculate a new alpha given a 0—0xff intensity
  def intensity(c, i)
    [c[0], c[1], c[2], (c[3] * i) >> 8]
  end

  # Calculate gradient colors
  def gradient_list(from, to, steps)
    delta = 4.times.map { |i| to[i] - from[i] }
    grad = []
    (steps + 1).times do |i|
      grad << 4.times.map { |j| from[j] + delta[j] * i / steps }
    end
    grad
  end

  def character(x0, y0, char, color)
    x = 0
    if CHARSET[char]
      CHARSET[char].each do |column|
        8.times do |y|
          y_mask = 2**(y - 7).abs
          point(x + x0, y + y0, color) if column & y_mask == y_mask
        end
        x += 1
      end
    else # any unknown character will appear as white space
      return 4 # whitespace width
    end
    x + 1 # returns char width
  end
end

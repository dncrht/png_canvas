# Based on Rui Carmo's PNGCanvas
# https://taoofmac.com/space/projects/PNGCanvas
# https://github.com/rcarmo/pngcanvas
# Reference: http://apidock.com/ruby/Array/pack

require 'zlib'

class PngCanvas

  VERSION = '0.0.1'

  CHARSET = {
    '0' => ['011110','100001','011110'],
    '1' => ['010001','111111','000001'],
    '2' => ['010001','100011','100101','011001'],
    '3' => ['010010','100001','101001','010110'],
    '4' => ['001100','010100','111111','000100'],
    '5' => ['111010','101001','101001','100110'],
    '6' => ['011110','100101','101001','000110'],
    '7' => ['100000','100011','101100','110000'],
    '8' => ['010110','101001','101001','010110'],
    '9' => ['011000','100101','101001','011110'],
    'A' => ['011111','100100','100100','011111'],
    'B' => ['111111','101001','101001','010110'],
    'C' => ['011110','100001','100001','010010'],
    'D' => ['111111','100001','100001','011110'],
    'E' => ['111111','101001','101001','100001'],
    'F' => ['111111','101000','101000','100000'],
    'G' => ['011110','100001','100101','010111'],
    'H' => ['111111','001000','001000','111111'],
    'I' => ['100001','111111','100001'],
    'J' => ['000010','000001','100001','111110'],
    'K' => ['111111','001000','010110','100001'],
    'L' => ['111111','000001','000001','000001'],
    'M' => ['111111','011000','011000','111111'],
    'N' => ['111111','011000','001110','111111'],
    'O' => ['011110','100001','100001','011110'],
    'P' => ['111111','100100','100100','011000'],
    'Q' => ['011110','100101','100011','011110'],
    'R' => ['111111','100100','100110','111001'],
    'S' => ['011001','100101','100101','100010'],
    'T' => ['100000','100000','111111','100000','100000'],
    'U' => ['111110','000001','000001','111110'],
    'V' => ['111100','000011','000011','111100'],
    'W' => ['111111','000110','000110','111111'],
    'X' => ['110011','001100','001100','110011'],
    'Y' => ['110000','001000','000111','001000','110000'],
    'Z' => ['100011','100101','101001','110001'],
    'a' => ['000110','001001','001010','001111'],
    'b' => ['111111','001001','001001','000110'],
    'c' => ['000110','001001','001001','001001'],
    'd' => ['000110','001001','001010','111111'],
    'e' => ['000110','001011','001101','000101'],
    'f' => ['000100','011111','100100','010000'],
    'g' => ['000100','0010101','0010101','001111'],
    'h' => ['111111','001000','001000','000111'],
    'i' => ['001001','101111','000001'],
    'j' => ['000001','0000001','101111'],
    'k' => ['111111','000100','000100','001011'],
    'l' => ['100001','111111','000001'],
    'm' => ['001111','001000','000110','001000','001111'],
    'n' => ['001111','000100','001000','000111'],
    'o' => ['000110','001001','001001','000110'],
    'p' => ['0011111','001010','001010','000100'],
    'q' => ['000100','001010','001010','0011111'],
    'r' => ['001111','000100','001000','000100'],
    's' => ['000101','001101','001011','001010'],
    't' => ['001000','111110','001001','000010'],
    'u' => ['001110','000001','000010','001111'],
    'v' => ['001110','000001','001110'],
    'w' => ['001110','000001','000111','000001','001110'],
    'x' => ['001001','000110','000110','001001'],
    'y' => ['001100','0000101','0000101','001111'],
    'z' => ['001001','001011','001101','001001'],
    '.' => ['000011','000011','000000'],
    ',' => ['00001101','0000111','000000'],
    ':' => ['0110110','0110110']
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

  def vertical_gradient(x0, y0, x1, y1, from, to)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    gradient = gradient_list(from, to, y1 - y0)
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

  def copy_rectangle(x0, y0, x1, y1, dx, dy, destination)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    (x0..x1).each do |x|
      (y0..y1).each do |y|
        destination.canvas[dy + y - y0][dx + x - x0] = @canvas[y][x]
      end
    end
  end

  def blend_rectangle(x0, y0, x1, y1, dx, dy, destination, alpha = 0xff)
    x0, y0, x1, y1 = rectangle_helper(x0, y0, x1, y1)
    (x0..x1).each do |x|
      (y0..y1).each do |y|
        rgba = @canvas[y][x] + [alpha]
        destination.point(dx + x - x0, dy + y - y0, rgba)
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

  def polyline(arr)
    (arr.size - 1).times do |i|
      line(arr[i].first, arr[i].last, arr[i + 1].first, arr[i + 1].last)
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

  def save(name)
    file = File.open name, 'wb'
    file.write dump
    file.close
  end

  def load(name)
    file = File.open name, 'rb'
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
    begin # any unknown character will appear as white space
      CHARSET[char].each do |col|
        y = 0
        col.each_char do |dot|
          point(x + x0, y + y0, color) if dot == '1'
          y += 1
        end
        x += 1
      end
    rescue
      return 4 # whitespace width
    end
    x + 1 # returns char width
  end
end

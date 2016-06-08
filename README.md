c = PngCanvas.new(512, 512)
        c.rectangle(0, 0, 512 - 1, 512 - 1)

        c.vertical_gradient(1, 1, 512 - 2, 512 - 2,
                            [0xff, 0, 0, 0xff], [0x20, 0, 0xff, 0x80])

        c.color = [0, 0, 0, 0xff]
        c.line(0, 0, 512 - 1, 512 - 1)
        c.line(0, 0, 512 / 2, 512 - 1)
        c.line(0, 0, 512 - 1, 512 / 2)

        c.copy_rect(1, 1, 512 / 2 - 1, 512 / 2 - 1, 1, 512 / 2, c)

        c.blend_rect(1, 1, 512 / 2 - 1, 512 / 2 - 1, 512 / 2, 0, c)
        c.save 'kk.png'

https://github.com/rcarmo/pngcanvas/blob/master/reference.png


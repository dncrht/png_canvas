require 'base64'

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size rescue 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

describe PngCanvas do

  it 'saves and loads a file successfully' do
    begin
      png = PngCanvas.new(4, 4)
      png.line(0, 0, 4, 4)
      saved_file = png.dump
      png.save 'test.png'
      png.load 'test.png'
      loaded_file = png.dump

      expect(saved_file).to eq loaded_file
    ensure
      FileUtils.rm 'test.png'
    end
  end

  it 'draws a diagonal line' do
    png = PngCanvas.new(4, 4)
    png.line(0, 0, 4, 4)

    expect(png.dump.size).to eq 100
    expect(Base64.encode64 png.dump).to eq <<-base64.strip_heredoc
      iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAIAAAAmkwkpAAAABnRSTlP/////
      //+evUsyAAAAGUlEQVR42mNgYGD4DwMgFpwPo8B8JDUMDACkuSPdNWcPMwAA
      AABJRU5ErkJggg==
    base64
  end

  it 'draws a red empty square' do
    png = PngCanvas.new(128, 64)
    png.color = [0xff, 0, 0, 0xff]
    png.rectangle(0, 0, 127, 63)

    expect(png.dump.size).to eq 193
    expect(Base64.encode64 png.dump).to eq <<-base64.strip_heredoc
      iVBORw0KGgoAAAANSUhEUgAAAIAAAABACAIAAABdtOgoAAAABnRSTlP/////
      //+evUsyAAAAdklEQVR42u3RsREAMAwCMfYfOval9AQ0+oMJlJdYcf+jUgAA
      AAAAAIAAABAAAAIAQAAACAAAAQAgAAAEAIAAABAAAAIAQAAACAAAAQAgAAAE
      AIAAABAAAAIAQAAACAAAAQAgAAAEAIAAABAAAAIAQAAA6AJYcQuila7hrshi
      HAAAAABJRU5ErkJggg==
    base64
  end

  it 'copies and pastes a rectangle' do
    png = PngCanvas.new(128, 64)
    png.color = [0xff, 0, 0, 0xff]
    png.rectangle(0, 0, 127, 63)
    png.vertical_gradient(1, 1, 126, 62,[0xff, 0, 0, 0xff], [0x20, 0, 0xff, 0x80])
    png.copy_rectangle(1, 1, 63, 31, 0, 32, png)
    png.blend_rectangle(1, 1, 63, 31, 64, 0, png)

    expect(png.dump.size).to eq 745
    expect(Base64.encode64 png.dump).to eq <<-base64.strip_heredoc
      iVBORw0KGgoAAAANSUhEUgAAAIAAAABACAIAAABdtOgoAAAABnRSTlP/////
      //+evUsyAAACnklEQVR42u3ca0/OARjH8duhREXlUEM5FCkUU9JBmcVa1mI0
      i7VYWBrN0miWlgd6wPa/y12KcppmqUYqRKNWE7JoNWFazaGtsrRVWKzGtV3v
      wb5m+7yAa/s+/e0yjZtMaGNkf+430QOMTrDi0gA/J1pzfZtky6UBvk+24xqy
      cuTSAMPWTlxfpzhzaYBBGxeu/qmuXBrgyzQ3rl5bdy4N0GfnwfXZ3otLA/RM
      9+b6MMOHSwN8dPDl6nL049IA3U7+XO9nBnJpgM5ZQVxvZodyaYC3c8K4XjuH
      c2mADpdNXG1zI7k0QPu8LVyv5kdzaYBW161cLW47uDTAywUxXM0LY7k0wItF
      u7ieLo7n0gDP3PdwPfHYx6UBmpbs52pYepBLAzR6JnHVLTvMpQHqvZK5Hnmn
      cGmAx8uPcj1ccZxLA9SuTOOq8Unn0gAPfE9y3VuVyaUB7q8+xVW95jSXBrjr
      l8VV6X+GSwNUrT3LVRFgcGmAO+vMXLcCLVwa4HZQLldZcD6XBigPKeAqXV/I
      pQHKQov++yvw8/SbG66iSQD0Nr1kYzGaBEBv02+El6BJAPQ2vXhzOZoEQG/T
      r0dUoEkA9Db9WmQ1mgRAb9OvRNWgSQD0Nv1ydC2aBEBv0y9tq0OTAOhteuH2
      RjQJgN6mX4xpQpMA6G36hZ3P0SQAepteENuCJgHQ2/T83a1oEgC9TT8f144m
      AdDb9Lz4DjQJgN6m5+59hyYB0Nt0S0InmgRAb9MtB7rRJAB6m34u8ROaBEBv
      03OSetAkAHqbnnOoF00CoLfp2cn9aBIAvU3PPjKAJgHQ23RzyiCaBEBv082p
      Q2gSAL1NN46NoEkA9DbdSPuBJgHQ23TjxCiaBEBv0430X2gSAD3vNjLG0f6F
      7+l0vwER6/0xkn8cOwAAAABJRU5ErkJggg==
    base64
  end

  it 'copies and pastes a rectangle wth text' do
    png = PngCanvas.new(128, 64)
    png.color = [0xff, 0, 0, 0xff]
    png.rectangle(0, 0, 127, 63)
    png.vertical_gradient(1, 1, 126, 62,[0xff, 0, 0, 0xff], [0x20, 0, 0xff, 0x80])
    png.copy_rectangle(1, 1, 63, 31, 0, 32, png)
    png.blend_rectangle(1, 1, 63, 31, 64, 0, png)
    png.color = [0, 0, 0, 0xff]
    png.text(0, 50, 'this is a 50,12')

    expect(png.dump.size).to eq 919
    expect(Base64.encode64 png.dump).to eq <<-base64.strip_heredoc
      iVBORw0KGgoAAAANSUhEUgAAAIAAAABACAIAAABdtOgoAAAABnRSTlP/////
      //+evUsyAAADTElEQVR42u3ce0yNcRzH8celXMqlXGool0oqFVMoxCxmmcVo
      FrMYGS3NymgW4w/+YDtJUeQ6zaJGCNGUaXJbNE2Yprm0JaMtt8U057t+e3b2
      nHOqzR+8TXut/Xp69pxn3uavz2htmob2k8z8/ho9QGs3By4V4Ht3R64vPZy4
      VICvPZ25WhxcuFSAT46uXB97uXGpAM293bma+nhwqQDv+3pyNTp5cakA75y9
      ud728+NSARr6+3O9GhDEpQK8HhjM9dIlhEsFqHcN5XoxKIxLBagbHM71dEgE
      lwrwbOhMridukVwqQK37HK7Hw6K4VICa4fO5Ho2I5lIBqj0WclV5LuFSAR6O
      jOG6PyqWSwV4MHoZ150xcVwqwF2vlVy3vddwqQCVPvFct8au51IBKnwTuMrH
      beBSAW76JXHd8E/mUgHKAlK4ro/fwqUClAamcpUEpXGpANeCt3FdmbCDSwW4
      OnEnV/GkXVwqwOWQ3VwXQ/dwqQCXJu/lKppi4lIBLkxN5zoXlsmlApwPz+Iq
      mJbNpQIUTs/hOjsjl0sFKIg48t8fgZ+nn5l1Ak0CoLfp+bPz0CQAept+OjIf
      TQKgt+l5cwvRJAB6m35qXhGaBEBv009GFaNJAPQ2/fiCEjQJgN6mH4suRZMA
      6G360UXlaBIAvU3PXVyBJgHQ2/TDMZVoEgC9TT+09B6aBEBv03Niq9AkAHqb
      nr28Gk0CoLfpB1fUoEkA9Db9QFwtmgRAb9OzVj1HkwDobXrm6jo0CVDpE69Z
      LNQ1q7W61rX9uvZ7M3fN4qvjBxre1vyVubYeSgJU+CZoFgt17Q+t1Q2fa/1i
      +nX9ovmwf90bM/2A02b596597W3zR30Lbvit4Xqnt3X6BMvP1b9b36mfMxIa
      zMxX2g84EqAsIEWzWKjrZ5sHzf6WvSu3WT/T3j3WL2b9ELOMxEb5009shJIA
      pYGp1t9tHvQfNVuL9q7cpn+EvV/ZfBnD/YbzvqQmLgnQPvK2d9D/ZTCcDbp4
      m+Vj7T3EcKfhus0PkgwbPxBJAMQG3d57pic3o0mAv3+A3sFLpm9qQZMA6G26
      afNnNAmA3qabUr+hSQD0Nt20tRVNAqC36aa0H2gSAD3vNm1vQ/sX/vd0ul8l
      RVvzUA6odwAAAABJRU5ErkJggg==
    base64
  end
end

class KernProcessor
  constructor: (@font) ->
    @kern = font.kern
    
  process: (glyphs, advances) ->
    for glyph, glyphIndex in glyphs
      break if glyphIndex + 1 >= glyphs.length
      
      left = glyphs[glyphIndex].id
      right = glyphs[glyphIndex + 1].id
      advances[glyphIndex] += @getKerning(left, right) * @font.scale
      
      
  getKerning: (left, right) ->
    for table in @kern.tables
      switch table.version
        when 0
          continue unless table.coverage.horizontal
        when 1
          continue if table.coverage.vertical
        else
          throw new Error "Unsupported kerning table version #{table.version}"
          
      s = table.subtable
      switch table.format
        when 0
          for pair in s.pairs
            if pair.left is left and pair.right is right
              return pair.value
              
        when 3
          return s.kernValue[s.kernIndex[s.leftClass[left] * s.rightClassCount + s.rightClass[right]]]
              
        else
          throw new Error "Unsupported kerning sub-table format #{table.format}"
          
    return 0
    
module.exports = KernProcessor

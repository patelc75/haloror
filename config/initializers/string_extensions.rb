# extend String class
class String
  # ASSUMPTION: evetything in the string is an integer or an integer-range
  # WARNING: any non-number within data will cause id be recognized as ZERO
  # logic is: split by ',', strip, split any range & collect arrays, keep everything as integers, flatten everything as array.
  def ranges_and_integers_as_array
    self.split(',').collect(&:strip).collect {|e| e.include?('-') ? (es = e.split('-'); (es[0].to_i..es[1].to_i).collect) : e.to_i }.flatten
  end
  
end

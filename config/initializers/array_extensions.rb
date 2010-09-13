# extensions to Array class

# Usage:
#   Expects: [ [], [], ...]
#   does not work with flat arrays like []
class Array
  def to_hash
    inject({}) { |m, e| m[e[0]] = e[1]; m }
  end
end

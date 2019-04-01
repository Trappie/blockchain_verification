# given a message of text string in form of utf-8, return the hashed value
# example:
# given 'bill'
# should return 'f896'
def hash(message)
  # given the utf-i encoding of some character, return the hash valud for the single char
  def hash_char(x)
    return ((x**3000) + (x**x) - (3**x)) * (7**x)
  end

  encodings = message.unpack('U*')

  hashed = encodings.map do |x|
    hash_char(x)
  end

  result = hashed.reduce(0, :+) % 65536
  return result.to_s(16)

end

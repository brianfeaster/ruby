require 'minitest/autorun'


class TestMeow < Minitest::Test
  Bignum x=5
  def test_a
    print 'meow'
  end
  def test_b
    test_a
  end
end

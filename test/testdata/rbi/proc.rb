# typed: strict
extend T::Sig

-> (x) { x }[123]

my_proc = Proc.new {}
T.reveal_type(my_proc) # error: type: `Proc`

sig {params(f: T.proc.params(x: Integer).void).void}
def example(f)
  f.call(0) do # error: `Proc1#call` does not take a block
    puts 'hello'
  end
end

f = ->(x, &blk) do
  puts x
  blk.call
end

example(f)
#       ^ error: Expected `T.proc.params(arg0: Integer).void` but found `T.proc.params(arg0: T.untyped, arg1: T.untyped).returns(T.untyped)` for argument `f`

f1 = T.let(proc { 1 }, T.proc.returns(Integer))
g1 = T.let(proc { |x| x.to_s }, T.proc.params(x: Integer).returns(String))
composed1 = f1 >> g1
T.reveal_type(composed1) # error: `T.proc.returns(String)`

f2 = T.let(proc { |x, y, z| x + y + z }, T.proc.params(x: Integer, y: Integer, z: Integer).returns(Integer))
g2 = T.let(proc { |x| x.to_s }, T.proc.params(x: Integer).returns(String))
composed2 = f2 >> g2
T.reveal_type(composed2) # error: `T.proc.params(arg0: Integer, arg1: Integer, arg2: Integer).returns(String)`

f3 = T.let(proc { |x| x.to_s }, T.proc.params(x: Integer).returns(String))
g3 = T.let(proc { |x| x * 2 }, T.proc.params(x: Integer).returns(Integer))
composed3 = f3 << g3
T.reveal_type(composed3) # error: `T.untyped`

f4 = T.let(proc { |x| x * 2 }, T.proc.params(x: Integer).returns(Integer))
sig {params(x: Integer).returns(String)}
def g4(x)
  x.to_s
end
composed4 = f4 >> method(:g4)
T.reveal_type(composed4) # error: `Proc`

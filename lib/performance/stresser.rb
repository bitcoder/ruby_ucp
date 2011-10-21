=begin
Ruby library implementation of EMI/UCP protocol v4.6 for SMS
Copyright (C) 2011, Sergio Freire <sergio.freire@gmail.com>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
=end

=begin
this file actually contais a LOT of garbage... used just to test things while developing
i left so you can take a look of concrete examples, while I build clean samples along
with tests
=end



$KCODE = 'UTF8'
require 'jcode'
require "rubygems"
require "ruby_ucp"
include Ucp::Util
require "benchmark"


def bench(test_name,test_code,*args)
    total_runs = 1000
    t=Benchmark.realtime { total_runs.times do; test_code.call(*args); end }
    puts "#{test_name}: #{(total_runs/t).to_i} req/sec"
end



def test_parse_str
   ustr=2.chr+"01/00357/O/51/961234567/1234/////////////////4/1072/0031003200330034003500360037003800390030003100320033003400350036003700380039003000310032003300340035003600370038003900300031003200330034003500360037003800390030003100320033003400350036003700380039003000310032003300340035003600370038003900300031003200330034003500360037//////////0106050003450201020108///01"+3.chr
   ucp=UCP.parse_str(ustr)
end

def test_make_multi_ucps(msg_size)
  UCP.make_multi_ucps(1235,961234568,"1234567890"*msg_size)
end

def test_ucp30_basic_submit(msg_size)
  ucp=Ucp30Operation.new
  ucp.basic_submit(1234, 961234567, "z"*msg_size)
end


puts "== Ruby UCP methods benchmark =="

bench("UCP.parse_str()",method(:test_parse_str))
bench("UCP.make_multi_ucps(sms_len=10)",method(:test_make_multi_ucps),1)
bench("UCP.make_multi_ucps(sms_len=100)",method(:test_make_multi_ucps),10)
bench("UCP.make_multi_ucps(sms_len=300)",method(:test_make_multi_ucps),30)

puts "== == =="

bench("Ucp30Operation.basic_submit(sms_len=10)",method(:test_ucp30_basic_submit),10)
bench("Ucp30Operation.basic_submit(sms_len=100)",method(:test_ucp30_basic_submit),100)
bench("Ucp30Operation.basic_submit(sms_len=300)",method(:test_ucp30_basic_submit),300)

puts "== == =="

=begin
    Benchmark.bm(7) do |x|
      x.report("for:")   { n.times do; ustr=2.chr+"01/00357/O/51/961234567/1234/////////////////4/1072/0031003200330034003500360037003800390030003100320033003400350036003700380039003000310032003300340035003600370038003900300031003200330034003500360037003800390030003100320033003400350036003700380039003000310032003300340035003600370038003900300031003200330034003500360037//////////0106050003450201020108///01"+3.chr
ucp=UCP.parse_str(ustr); end }
      x.report("times:") { n.times do   ; a = "1"; end }
      x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
    end
=end
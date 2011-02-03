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

def handle_me(smsreq) 
  puts "handle_me [#{smsreq.source_ip}:#{smsreq.source_port}] (#{smsreq.originator},#{smsreq.recipient})  (#{smsreq.part_nr}/#{smsreq.total_parts}): #{smsreq.text}\n"
end

def auth_handler(authreq)
  puts "auth_handler [#{authreq.source_ip}:#{authreq.source_port}] (#{authreq.account},#{authreq.password})\n"
  return true
end


#ucp=UCP.parse_str("*00/00113/O/51/961234567/1234/////////////////4/120/B49AED86CBC162B219AD66BBE17230//////////0106050003450202///90#")
#puts "UCP: #{ucp.to_s}"
#exit





ucp=Ucp31Operation.new
puts "UCP: #{ucp.to_s}"
ucp=Ucp30Operation.new
ucp.basic_submit(1234, 961234567, "ola")
puts "UCP: #{ucp.to_s}"



ustr=2.chr+"01/00357/O/51/961234567/1234/////////////////4/1072/0031003200330034003500360037003800390030003100320033003400350036003700380039003000310032003300340035003600370038003900300031003200330034003500360037003800390030003100320033003400350036003700380039003000310032003300340035003600370038003900300031003200330034003500360037//////////0106050003450201020108///01"+3.chr
ucp=UCP.parse_str(ustr)

ucp.set_fields({:oadc=>"10412614190438AB4D",:otoa=>"5039"})
text=UCP.decode_ucp_msg(ucp)
originator=UCP.decode_ucp_oadc(ucp)
puts "originator: #{originator} ; text: #{text}"

#exit


puts UCP.str2ucs2("ola").encoded

s="1234567890"*7 +"1€"
UCP.make_multi_ucps(1235,961234568,s)

#exit

puts "1€€".length,"1€€".jlength
puts "1€"[1..1]
puts "1€".chars #[0..1]
"1€".each_char{ |c|
  puts "C: #{c}"
}
#exit


#exit

ucp=Ucp01Operation.new
ucp.basic_submit("1234x",961234567,"ola")
#ucp.set_fields( {:mt=>"4", :oadc=>"x"})
ucp.trn="02"
puts ucp.to_s


port=12009
server=UcpServer.new(method(:handle_me),port)
server.set_authentication_handler(method(:auth_handler))

cliente=UcpClient.new("localhost",port,{:login=>8006,:password=>"timor"})
#sent=cliente.send_message(1234,961234567,"1234567890"*17+"ola custa 1€ sabias?")

ans=cliente.send_alert("961234567","0100")
puts "ans: #{ans}"
s="1234567890"*8+"1€"
sent=cliente.send_message(1234,961234567,s)
puts "sent: #{sent}"
ucp=Ucp30Operation.new
ucp.basic_submit(1234, 961234567, "ola 1€éuro Ç!@\'\"#\$%&/()=<>,.-;:*+[]")
ans=cliente.send_sync(ucp)
puts "ans: #{ans}"
cliente.close
server.stop
exit





ucp=UCP.parse_str("*00/00113/O/51/961234567/1234/////////////////4/120/B49AED86CBC162B219AD66BBE17230//////////0106050003450202///90#")
puts ucp.to_s


puts UCP.pack7bits("€")
#puts UCP.packucs2("ola")
puts UCP.decode7bitgsm(UCP.pack7bits("1234567890"*17))
gsmparts= UCP.pack7bits2("1234567890"*17,134)
puts "septets: #{gsmparts.required_septets} ;  unenc: #{gsmparts.unencoded}"
gsmparts= UCP.multi_pack7bits2("1234567890"*17,134)
gsmparts.each { |gsmpart|
  puts "part: #{gsmpart.unencoded}"
}

UCP.make_multi_ucps(1235,961234568,"1234567890"*17)

str= UCP.pack7bits("1234567890"*17)
smparts=[]
i=0
while i*2<str.length
  tmp= str[i*2,(i+134)*2]
  puts "tmp.len. #{tmp.length/2} ; TMP: #{tmp}"
  puts UCP.decode7bitgsm(tmp)
  smparts << tmp
  i+=134
end

puts str.length/2
puts str.length*8/14
#exit

#ucp=Ucp51Operation.new("1234x",961234567,"ola")
#ucp.set_fields( {:mt=>"4", :oadc=>"x"})
#ucp.add_xser_raw("020101")
#ucp.add_xser("03","01")
#ucp.trn="02"
#puts ucp.to_s



ucp=Ucp01Result.new
ucp.ack("ok")
puts ucp.to_s
puts ucp.is_nack?

ucp=Ucp01Result.new
ucp.nack("02","bla")
ucp.trn="12"
puts ucp.to_s
puts ucp.is_nack?

ucp=Ucp60Result.new()
ucp.ack("ok")
puts ucp.to_s
puts ucp.is_nack?



cliente=UcpClient.new("localhost",12000,{:login=>8006,:password=>"timor"})
ucp=Ucp51Operation.new(1234,961234567,"ola")
ans=cliente.send_sync(ucp)

if ans.is_ack?
  puts "aceite!"
else
  puts "rejeitado!"
end

cliente.close

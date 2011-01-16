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

class Ucp::Util::GsmPackedMsg < Ucp::Util::PackedMsg


#  attr_reader :encoded,:unencoded,:chars,:required_septets,:part_nr,:total_parts,:message_ref
  
  @encoded=""
  @unencoded=""
  @required_septets=0
  @chars=0

  # ??
  #@dcs=nil

#  @part_nr=nil
#  @total_parts=nil
#  @message_ref=nil

  def initialize(encoded,unencoded,chars,required_septets,tainted=false)
    @encoded=encoded
    @unencoded=unencoded
    @chars=chars
    @required_septets=required_septets
    @tainted=tainted

#    @part_nr=1
#    @total_parts=1
#    @message_ref=0
  end


end

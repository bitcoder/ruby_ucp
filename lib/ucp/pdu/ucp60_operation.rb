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


class Ucp::Pdu::Ucp60Operation < Ucp::Pdu::UCP60

   def initialize(fields=nil)
    super()
    #@operation="60"
    @operation_type="O"
    @fields=[:oadc,:oton,:onpi,:styp,:pwd,:npwd,:vers,:ladc,:lton,:lnpi,:opid,:res1]

    if fields.nil?
      return
    end


    @trn=fields[0]
    @operation_type=fields[2]
    @operation=fields[3]

     # *00/00050/O/60/8006/6/5/1/F474FB2D07//0100//////15#

     for i in 4..(fields.length-1)
       field=@fields[i-4]
       @h[field]=fields[i]
     end

  end




 def basic_auth(originator,password,ucpfields={})
    #super()
    #@operation_type="O"
    
    @h={:oadc=>originator, :pwd=>UCP.ascii2ira(password), :vers=>"0100", :styp=>"1", :oton=>"6",:onpi=>"5"}
    @h=@h.merge ucpfields
  end

end
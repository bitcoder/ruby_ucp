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

class Ucp::Pdu::Ucp01Operation  < Ucp::Pdu::UCP01

  def initialize(fields=nil)
    super()
    @operation_type="O"
    @fields=[:adc,:oadc,:ac,:mt,:msg]

    if fields.nil?
      return
    end

    @trn=fields[0]
    @operation_type=fields[2]
    @operation=fields[3]

    # *02/00050/O/01/961234567/0931D98C8607//3/6F7618/72#

     for i in 4..(fields.length-1)
       field=@fields[i-4]
       @h[field]=fields[i]
     end


  end

 def basic_submit(originator,recipient,message,ucpfields={})
    #super()
    #@operation_type="O"
    #@fields=[:adc,:oadc,:ac,:mt,:msg]

    # UCP01 only supports IRA encoded SMS (7bit GSM alphabet chars, encoded in 8bits)
    msg=UCP.ascii2ira(message).encoded

    # UCP01 does NOT support alphanumeric oadc
    oadc=originator

    @h={:oadc=>oadc, :adc=>recipient, :msg=>msg,:mt=>3}
    
    @h=@h.merge ucpfields
  end

end

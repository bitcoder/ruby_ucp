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


class Ucp::Pdu::Ucp51Operation < Ucp::Pdu::UCP5x

   def initialize(fields=nil)
    super()
    @operation="51"
    @operation_type="O"
    #@fields=[:adc,:oadc,:ac,:nrq,:nadc,:nt,:npid,:lrq,:lrad,:lpid,:dd,:ddt,:vp,:rpid,:scts,:dst,:rsn,:dscts,:mt,:nb,:msg,:mms,:pr,:dcs,:mcls,:rpi,:cpg,:rply,:otoa,:hplmn,:xser,:res4,:res5]
    
    if fields.nil?
      return
    end

    
    @trn=fields[0]
    @operation_type=fields[2]
    @operation=fields[3]
#    *00/00352/O/51/961234567/1234/////////////////4/1072/31D98C56B3DD7039584C36A3D56C375C0E1693CD6835DB0D9783C564335ACD76C3E56031D98C56B3DD7039584C36A3D56C375C0E1693CD6835DB0D9783C564335ACD76C3E56031D98C56B3DD7039584C36A3D56C375C0E1693CD6835DB0D9783C564335ACD76C3E56031D98C56B3DD7039584C36A3D56C375C0E1693CD6835DB0D9783C56433//////////0106050003450201///44#

     for i in 4..(fields.length-1)
       field=@fields[i-4]
       if field.eql?(:xser)
         add_xser_raw(fields[i])
       else
         @h[field]=fields[i]
       end
     end
     
     parse_xser

  end







 def parse_xser
   @xservices.each { |xser|

     puts "xser_id: #{xser[0,2]}"
     
     if xser[0,2].eql?("01")
        header=xser[4,xser[2,2].to_i(16)*2]
        header_len=xser[4,2].to_i(16)
        #puts "header: #{header}; hlen: #{header_len}"

        i=2
        while i<header.length
          ie=header[i, header[i+2,2].to_i(16)*2+4]
          iei=header[i,2]
          iel=header[i+2,2].to_i(16)
          #puts "ie: #{ie}"

          if iei.eql?("00")
            @message_ref=ie[4,2].to_i(16)
            @total_parts=ie[6,2].to_i(16)
            @part_nr=ie[8,2].to_i(16)
            #puts "part_info: MR=#{@message_ref}; PN=#{@part_nr} PT=#{@total_parts}"
            break
          end
          i+=iel*2
        end       
     elsif xser[0,2].eql?("02")
       @dcs=xser[4,2]
     end
   }

   # no parts info
   return nil
 end


 def add_xser_raw(xser)

  # nao faz parsing/decode do xser
  #@xservices << xser

   # partir os xservices, por form a fazer parsing dos mesmos e adiciona-los um a um
   idx=0
   while idx<xser.length
    xser_id=xser[idx,2]
    xser_len=xser[idx+2,2].to_i(16)
    xser_data=xser[idx+4,xser_len*2]

    #puts "xxx_serid: #{xser_id} ; #{xser_data}"
    add_xser(xser_id,xser_data)
    idx+=(xser_len+2)*2
   end

 end

 def add_xser(xser_id,xser_data)
   xser=xser_id+UCP.int2hex(xser_data.length/2)+xser_data
   @xservices << xser

   if xser_id.eql?("02")
     @dcs=xser_data
   end
 end

 def basic_submit(originator,recipient,message=nil,ucpfields={})
#    super()
#    @operation="51"
#    @operation_type="O"
#    @fields=[:adc,:oadc,:ac,:nrq,:nadc,:nt,:npid,:lrq,:lrad,:lpid,:dd,:ddt,:vp,:rpid,:scts,:dst,:rsn,:dscts,:mt,:nb,:msg,:mms,:pr,:dcs,:mcls,:rpi,:cpg,:rply,:otoa,:hplmn,:xser,:res4,:res5]

    # UCP51 supports IRA encoded SMS and 16 bits UCS2
    # for now assume IRA
    if !message.nil?
      msg=UCP.ascii2ira(message)
    end
    mt=3


    otoa=""

    # UCP51 supports alphanumeric oadc
    if originator.to_s !~ /^[0-9]+$/
      oadc=UCP.packoadc(originator.to_s)
      otoa="5039"
    else
      oadc=originator
    end



    @h={:otoa=>otoa,:oadc=>oadc, :adc=>recipient, :msg=>msg,:mt=>mt}

    @h=@h.merge ucpfields
  end

  def to_s

   xserstr=""
   if !@xservices.empty?
     @xservices.each { |xser|
      xserstr+=xser
     }
     @h[:xser]=xserstr
   end

   super()
  end

end


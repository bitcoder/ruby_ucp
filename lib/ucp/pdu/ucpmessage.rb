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

module Ucp::Pdu


class UCPMessage 
  DELIMITER="/"
  STX=2.chr
  ETX=3.chr


  @fields=[]
  @h={}

#  @@trn="00"
  attr_reader :operation
  attr_reader :operation_type
  attr_accessor :trn
  attr_reader :dcs
  attr_reader :message_ref, :part_nr, :total_parts

  # usado pelas classes que o extendem
  def initialize()
    @dcs="01"

    @trn="00"
    @fields=[]
    @h=Hash.new

    @message_ref=0
    @part_nr=1
    @total_parts=1
  end

  def get_field(field)
    return @h[field]
  end

  def set_field(field,value)
    @h[field]=value
  end

  def set_fields(ucpfields={})
    @h=@h.merge ucpfields
  end


  def is_operation?
    return @operation_type=="O"
  end

  def is_result?
    return @operation_type=="R"
  end

    def is_ack?
    return @h.has_key?(:ack)
  end

  def is_nack?
    return @h.has_key?(:nack)
  end
  
  def checksum(s)
    # The <checksum> is derived by the addition of all bytes of the header, data field separators
    # and data fields (i.e. all characters after the stx-character, up to and including the last “/”
    # before the checksum field). The 8 Least Significant Bits (LSB) of the result is then
    # represented as two printable characters.

    sum=0
    s.each_byte { |byte|
      sum+=byte
    }
    #return sprintf("%02x",sum)[-2,2]
    return sum.to_s(16)[-2,2].upcase
  end

  def length(s)
    return sprintf("%05d",s.length+16)
  end

  def to_s

    s=""
    @fields.each{ |key|
      value=@h[key]
      if value.nil?
        s+=DELIMITER
      else
        s+=value.to_s+DELIMITER
      end
    }


    pdu=@trn+DELIMITER
    pdu+=length(s)+DELIMITER
    pdu+=@operation_type+DELIMITER
    pdu+=@operation+DELIMITER
    pdu+=s
    pdu+=checksum(pdu)
    pdu=STX+pdu+ETX
    return pdu
  end

end # class


end # module
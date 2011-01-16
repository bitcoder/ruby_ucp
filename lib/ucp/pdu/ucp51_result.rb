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


class Ucp::Pdu::Ucp51Result < Ucp::Pdu::UCP5x

  def initialize(fields=nil)
    super()
    @operation="51"
    @operation_type="R"
    if fields.nil?
      return
    end

    @trn=fields[0]
    if fields[4].eql?("A")
      # 00/00039/R/51/A//012234:090996101010/68
      ack(fields[5],fields[6])
    elsif fields[4].eql?("N")
      # 00/00022/R/51/N/31//07
      nack(fields[5],fields[6])
    else
      raise "invalid result in UCP51"
    end

    # TODO: verificar len e checksum

  end


  def ack(mvp="",sm="")
    @fields=[:ack,:sm]
    @h[:ack]="A"
    @h[:mvp]=mvp
    @h[:sm]=sm
  end

  def nack(ec,sm="")
    @fields=[:nack,:ec,:sm]
    @h[:nack]="N"
    @h[:ec]=ec
    @h[:sm]=sm
  end



end


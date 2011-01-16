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


class Ucp::Util::SmsRequest

  attr_reader :source_ip, :source_port, :originator, :recipient, :text, :account, :message_ref, :part_nr, :total_parts

  def initialize(originator,recipient,text,account=nil,source_ip=nil,source_port=nil)
    @account=account
    @source_ip=source_ip
    @source_port=source_port
    @originator=originator
    @recipient=recipient
    @text=text
  end

  def set_parts_info(message_ref,part_nr,total_parts)
    @message_ref=message_ref
    @part_nr=part_nr
    @total_parts=total_parts
  end

  def complete?
    return @total_parts==1
  end

  def partial?
    return @total_parts>1
  end

end

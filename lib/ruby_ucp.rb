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


$:.unshift(File.dirname(__FILE__))

require "ucp/base.rb"
require "ucp/pdu/ucpmessage.rb"
require "ucp/pdu/ucp01.rb"
require "ucp/pdu/ucp30.rb"
require "ucp/pdu/ucp31.rb"
require "ucp/pdu/ucp5x.rb"
require "ucp/pdu/ucp60.rb"
require "ucp/pdu/ucp61.rb"
require "ucp/util/base.rb"


# Load all YCP PDUs
Dir.glob(File.join(File.dirname(__FILE__), 'ucp', 'pdu', '*.rb')) do |f|
  require f  unless f.match('ucpmessage.rb$')
end

# Load all auxiliary classes
Dir.glob(File.join(File.dirname(__FILE__), 'ucp', 'util', '*.rb')) do |f|
  require f  unless f.match('base.rb$')
end
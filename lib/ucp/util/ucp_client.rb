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


require "socket"

include Ucp::Pdu
include Ucp::Util

class Ucp::Util::UcpClient

  @trn=0
  @mr=0
  
 attr_accessor :host,:port,:local_host,:local_port

  def initialize(host,port,local_host=nil,local_port=nil,authcreds=nil)
    @host=host
    @port=port
    @local_host=local_host
    @local_port=local_port
    @connected=false
    @authcreds=authcreds
    @trn=0
    @mr=0
    connect()
  end

  def connect
    #puts "connect()"
    
    begin
        @socket = TCPSocket.new(@host, @port,@local_host,@local_port)
        @connected=true
        @trn=0
    rescue
        @connected=false
        return false
    end


    if !@authcreds.nil?
      auth_ucp=Ucp60Operation.new
      auth_ucp.basic_auth(@authcreds[:login],@authcreds[:password])
      auth_ucp.trn="00"
      answer=send_sync(auth_ucp)
      #puts "Crecv: #{answer.to_s}\n"
      
      if !answer.nil? && answer.is_ack?
        inc_trn()
        return true
      else
        close()
        return false
      end
    end

  end

  def close
    begin
      @socket.close
    rescue
    end
    @connected=false
  end

  def connected?
    if !@socket.nil? && !@socket.closed? && @connected
      @connected=true
    else
      @connected=false
    end
    return @connected
  end

  def send_sync(ucp)
    #puts "XXXX0"

    if !connected?
      connect()
      # se nao foi possivel ligar, retornar imediatamente com erro
      if !connected?
        return nil
      end
    end

    #puts "XXXX1"
    
    answer=nil
    begin
        @socket.print ucp.to_s
        puts "Csent: #{ucp.to_s}\n"
        answer = @socket.gets(3.chr)
        #answer = @socket.gets("#")
        puts "Crecv: #{answer.to_s}\n"
    rescue
        puts "error: #{$!}"
        @connected=false
    end

    # verificar o trn da resposta face a submissao
    replyucp=UCP.parse_str(answer)
    return nil if replyucp.nil?

    if !ucp.trn.eql?(replyucp.trn)
      puts "unexpected trn #{replyucp.trn}. should be #{ucp.trn}"
      return nil
    else
      return replyucp
    end
  end

  def send(ucp)
    if !connected?
      connect()
      # se nao foi possivel ligar, retornar imediatamente com erro
      if !connected?
        return false
      end
    end

    begin
        @socket.print ucp.to_s
    rescue
        puts "error: #{$!}"
        # deu erro, vamos fechar o socket
        close()
        # error
        return false
    end

    # OK
    return true
  end

  def read
    answer=nil
    begin
        answer = @socket.gets(3.chr)
    rescue
        puts "error: #{$!}"
        # deu erro, vamos fechar o socket
        close()
    end

    return answer
  end

  def send_message(originator,recipient,message)
    #ucp=Ucp51Operation.new(originator,recipient,message)

    ucps=UCP.make_multi_ucps(originator,recipient,message,@mr)
    inc_mr()

    ucps.each { |ucp|      
      ucp.trn=UCP.int2hex(@trn)
      ans=send_sync(ucp)
      inc_trn()
#      puts "e um ack: #{ans.nil?} ; #{ans.is_ack?}"
      return false if ans.nil? || !ans.is_ack?
    }


    return true
  end


  def send_alert(recipient,pid)
    ucp=Ucp31Operation.new
    ucp.basic_alert(recipient,pid)

    trn=UCP.int2hex(@trn)
    ucp.trn=trn
    ans=send_sync(ucp)
    inc_trn()
#      puts "e um ack: #{ans.nil?} ; #{ans.is_ack?}"
    return false if ans.nil? || !ans.is_ack?

    return true
  end



  def inc_trn
   @trn+=1
   @trn=0 if @trn>99
  end

  def inc_mr
   @mr+=1
   @mr=0 if @mr>255
  end

end

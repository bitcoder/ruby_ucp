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


require "iconv"

$KCODE = 'UTF8'
require 'jcode'

include Ucp::Pdu

class Ucp::Util::UCP

  @gsmtable={}
  @asciitable={}
  @extensiontable={}
  @extensiontable_rev={}

  :private
  def self.add_char(value,char)
    @gsmtable[char]=value
    @asciitable[value]=char
  end

  :private
  def self.add_extchar(value,char)
    @extensiontable[char]=value
    @extensiontable_rev[value]=char
  end

  def self.initialize_ascii2ira
    
    ('A'..'Z').each { |c|
      add_char(c[0],c)
    }
    ('a'..'z').each { |c|
      #@gsmtable[c]=c[0]
      #@asciitable[c[0]]=c
      add_char(c[0],c)
    }
    ('0'..'9').each { |c|
      add_char(c[0],c)
    }


    add_char(0x00,"@")
    add_char(0x01,"£")
    add_char(0x02,"$")
    #add_char(0x03," ")
    add_char(0x04,"è")
    add_char(0x05,"é")
    add_char(0x06,"ù")
    add_char(0x07,"ì")
    add_char(0x08,"ò")
    add_char(0x09,"Ç")
    add_char(0x0A,"\n")
    #add_char(0x0B," ")
    #add_char(0x0C," ")
    add_char(0x0D,"\r")
    #add_char(0x0E,"A")
    #add_char(0x0F,"a")

    add_char(0x1F,"É")



    add_char(0x20," ")
    add_char(0x21,"!")
    add_char(0x22,'"')
    add_char(0x23,"#")
    #add_char(0x24," ")
    add_char(0x25,"%")
    add_char(0x26,"&")
    add_char(0x27,"'")
    add_char(0x28,"(")
    add_char(0x29,")")
    add_char(0x2A,"*")
    add_char(0x2B,"+")
    add_char(0x2C,",")
    add_char(0x2D,"-")
    add_char(0x2E,".")
    add_char(0x2F,"/")

    add_char(0x3A,":")
    add_char(0x3B,";")
    add_char(0x3C,"<")
    add_char(0x3D,"=")
    add_char(0x3E,">")
    add_char(0x3F,"?")



    #@extensiontable["€"]=0x65
    #@extensiontable_rev[0x65]="€"
    add_extchar(0x65,"€")
    add_extchar(0x14,"^")
    add_extchar(0x28,"{")
    add_extchar(0x29,"}")
    add_extchar(0x2F,"\\")
    add_extchar(0x3C,"[")
    add_extchar(0x3D,"~")
    add_extchar(0x3E,"]")
    add_extchar(0x40,"|")



  end

  def self.pack7bits(str)
    #UCP.initialize_ascii2ira
    
    s=""
    str.each_char  { |c|

      ext=""
      gsmchar=@gsmtable[c]

      if gsmchar.nil?
        if @extensiontable.has_key?(c)
          ext="0011011" # 1B
          gsmchar=@extensiontable[c]
        else
          gsmchar=@gsmtable[" "]
        end
      end

      #gsmchar=c[0]
      #puts "#{c} : #{gsmchar} xxx"
      #gsmchar=@gsmtable[" "] if gsmchar.nil?
      
      tmp= gsmchar.to_s(2)

      remainder=tmp.length%7
      if remainder!=0
        nfillbits=7-remainder
        tmp="0"*nfillbits+tmp
      end
      
      s=tmp+ext+s

    }

    remainder=s.length%8
    if remainder!=0
      nfillbits=8-remainder
      s="0"*nfillbits+s
    end

    #puts "S: #{s}"
    
    i=s.length-8
    hexstr=""
    while i>=0
      c=s[i,8]

      tmp=c.to_i(2).to_s(16).upcase
      if tmp.length==1
        tmp="0"+tmp
      end
      #      puts tmp
      hexstr+=tmp
      i-=8
    end

    

    return hexstr
  end


  def self.pack7bits2(str,max_bytes)

    tainted=false
    s=""
    idx=0
    str.each_char  { |c|

      ext=""
      gsmchar=@gsmtable[c]

      if gsmchar.nil?
        if @extensiontable.has_key?(c)
          ext="0011011" # 1B
          gsmchar=@extensiontable[c]
        else
          gsmchar=@gsmtable[" "]
          tainted=true
        end
      end

      #gsmchar=c[0]
      #puts "#{c} : #{gsmchar} xxx"
      #gsmchar=@gsmtable[" "] if gsmchar.nil?

      tmp= gsmchar.to_s(2)

      remainder=tmp.length%7
      if remainder!=0
        nfillbits=7-remainder
        tmp="0"*nfillbits+tmp
      end

      # if adding this character exceeds the max allowed nr of bytes, break
      if ((tmp+ext+s).length*1.0/8).ceil>max_bytes
        break
      end

      s=tmp+ext+s

      # if reached the max allowed nr of bytes, break
      if (s.length*1.0/8).ceil==max_bytes
        idx+=1
        break
      end
      
      idx+=1
    }


    required_septets=s.length/7
    remainder=s.length%8
    if remainder!=0
      nfillbits=8-remainder
      s="0"*nfillbits+s
    end

    #puts "S: #{s}"

    i=s.length-8
    hexstr=""
    while i>=0
      c=s[i,8]

      tmp=c.to_i(2).to_s(16).upcase
      if tmp.length==1
        tmp="0"+tmp
      end
      #      puts tmp
      hexstr+=tmp
      i-=8
    end


    return GsmPackedMsg.new(hexstr,str[0,idx],idx,required_septets,tainted)
  end

  # @deprecated remove because unecessary
  def self.multi_pack7bits(str,max_bytes)
    msgparts=[]
    idx=0
    while true
      packedmsg=UCP.pack7bits2(str[idx..-1],max_bytes)
      msgparts<<packedmsg
      if idx+packedmsg.chars<str.length
        idx+=packedmsg.chars
      else
        break
      end
    end
    return msgparts
  end


  # convert standard string to IRA encoded hexstring
  def self.ascii2ira(str,max_bytes=nil)

    tainted=false  # true if not able to convert a character
    s=""
    idx=0
    str.each_char  { |c|
      gsmchar=@gsmtable[c]

      ext=""
      if gsmchar.nil?
        if @extensiontable.has_key?(c)
          ext="1B"
          gsmchar=@extensiontable[c]
        else
          gsmchar=@gsmtable[" "]
          tainted=true
        end
      end


      tmp=int2hex(gsmchar)


      if !max_bytes.nil?
        # if adding this character exceeds the max allowed nr of bytes, break
        if ((tmp+ext+s).length*7.0/16).ceil>max_bytes
          break
        end
      end

      s+=ext+tmp
      idx+=(ext+tmp).length/2

      # if reached the max allowed nr of bytes, break
      #    if (s.length*7.0/16).floor==max_bytes
      #      break
      #    end

    }

    required_septets=s.length/2
    #puts "idx: #{idx}; req_sep: #{required_septets}"
    return GsmPackedMsg.new(s,UCP.utf8_substr(str,0,idx-1),idx,required_septets,tainted)
  end


  def self.utf8_substr(str,idxs,idxe=nil)
    s=""
    i=0
    idxe=str.jlength-1 if idxe.nil?
    str.each_char{ |c|
      s+=c if i>=idxs and i<=idxe
      i+=1
    }
    return s
  end

  def self.multi_ascii2ira(str,max_bytes)
    msgparts=[]
    idx=0

    if str.jlength<=160
      packedmsg=UCP.ascii2ira(UCP.utf8_substr(str,idx),140)
      #puts "pckd_chars: #{packedmsg.chars}; strlen: #{str.jlength}"
      if packedmsg.chars==str.jlength
        msgparts<<packedmsg
        return msgparts
      end
    end

    while true
      #packedmsg=UCP.ascii2ira(str[idx..-1],max_bytes)
      #puts "bla: #{UCP.utf8_substr(str,idx)}"
      packedmsg=UCP.ascii2ira(UCP.utf8_substr(str,idx),max_bytes)
      msgparts<<packedmsg
      #break
      #puts "idx: #{idx}; pckd_chars: #{packedmsg.chars}; strlen: #{str.jlength}"
      
      #puts "sL: #{UCP.utf8_substr(str,idx,idx+packedmsg.chars- 1)} ; #{str[0,idx+packedmsg.chars].length}#"

      #if idx+packedmsg.chars<str.length
      if idx+packedmsg.chars<str.jlength
        idx+=packedmsg.chars
      else
        break
      end
    end
    return msgparts
  end


  def self.str2ucs2(str,max_bytes=nil)
    hexstr=""
    str=Iconv.iconv("utf-16be", "utf-8", str).first
    i=0
    str.each_byte{ |c|
      hexstr+=UCP.int2hex(c)
      i+=1
      if (!max_bytes.nil?) && (i == max_bytes)
        break
      end
    }

    return Ucs2PackedMsg.new(hexstr,UCP.utf8_substr(str,0,i-1),i/2,i)
  end

  def self.multi_ucs2(str,max_bytes)
    msgparts=[]
    idx=0

    if str.jlength<=70
      packedmsg=UCP.str2ucs2(str,140)
      #puts "pckd_chars: #{packedmsg.chars}; strlen: #{str.jlength}"
      if packedmsg.chars==str.jlength
        msgparts<<packedmsg
        return msgparts
      end
    end

    while true

      #puts "bla: #{UCP.utf8_substr(str,idx)}"
      packedmsg=UCP.str2ucs2(UCP.utf8_substr(str,idx),max_bytes)
      msgparts<<packedmsg
      #break
      #puts "idx: #{idx}; pckd_chars: #{packedmsg.chars}; strlen: #{str.jlength}"
      #puts "sL: #{UCP.utf8_substr(str,idx,idx+packedmsg.chars- 1)} ; #{str[0,idx+packedmsg.chars].length}#"

      if idx+packedmsg.chars<str.jlength
        idx+=packedmsg.chars
      else
        break
      end
    end
    return msgparts
  end



  def self.make_multi_ucps(originator,recipient,message,mr=0)
    ucps=[]

    gsm7bit_encodable=false

    if gsm7bit_encodable
      gsmparts= UCP.multi_ascii2ira(message,134)
    else
      gsmparts= UCP.multi_ucs2(message,134)
    end


    part_nr=1
    gsmparts.each { |gsmpart|
      ucp=Ucp51Operation.new
      ucp.basic_submit(originator,recipient,nil)

      if gsmparts.length>1
        # concatenated xser
        ucp.add_xser("01","050003"+UCP.int2hex(mr)+UCP.int2hex(gsmparts.length)+UCP.int2hex(part_nr))
      end

      if gsm7bit_encodable
        ucp.set_fields({:mt=>3, :msg=>gsmpart.encoded})
        # DCS xser
        ucp.add_xser("02","01")
      else
        ucp.set_fields({:msg=>gsmpart.encoded,:mt=>4,:nb=>gsmpart.encoded.length*4})
        # DCS xser
        ucp.add_xser("02","08")
      end

      #ucp.trn=UCP.int2hex(initial_trn)
      #initial_trn+=1

      #puts "part: #{ucp.to_s}"
      ucps<<ucp
      part_nr+=1
    }
    return ucps
  end



  def self.packucs2(str)
    hexstr=""
    s= Iconv.iconv("ucs-2be", "utf-8", str).first
    s.each_char{ |c|

      tmp=c[0].to_s(16).upcase
      if tmp.length==1
        tmp="0"+tmp
      end

      hexstr+=tmp

    }
    #puts s
    return hexstr
  end

  def self.packoadc(oa)
    packedoa=UCP.pack7bits(oa)

    # esta conta nao esta correcta... por causa das extensoes...
    #useful_nibbles=packedoa.length
    useful_nibbles=(oa.length*7.0/4).ceil

    tmp=useful_nibbles.to_s(16).upcase
    if tmp.length==1
      tmp="0"+tmp
    end

    return tmp+packedoa
  end

  def self.hextobin(hstr)
    bstr=""
    i=0
    while i<hstr.length
      tmp=hstr[i,2].to_i(16).to_s(2)

      nfillbits=8-tmp.length
      if nfillbits!=0
        tmp="0"*nfillbits+tmp
      end

      bstr+=tmp
      i+=2
    end
    return bstr
  end


  def self.hextobin_reversed(hstr)
    bstr=""
    i=0
    while i<hstr.length
      tmp=hstr[i,2].to_i(16).to_s(2)

      nfillbits=8-tmp.length
      if nfillbits!=0
        tmp="0"*nfillbits+tmp
      end

      bstr=tmp+bstr
      i+=2
    end
    return bstr
  end


  def self.decode7bitgsm(str)
    
    # retirar isto!!
    #initialize_ascii2ira
    
    unencoded=""
    #puts "#{str}"
    bstr=UCP.hextobin_reversed(str)
    #puts "#{bstr}"
    # 110 1111 110 1100 110 0001
    # 1000011 1011101 0110111   000

    i=bstr.length-7
    while i>=0
      value=bstr[i,7].to_i(2)
      if value==0x1B
        i-=7
        value=@extensiontable_rev[bstr[i,7].to_i(2)]
        value=" " if value.nil?
        unencoded+=value
      else
        val=@asciitable[value]
        #puts "value: #{value} ; val: #{val}"
        val=" " if val.nil?
        unencoded+=val
        #unencoded+=value.chr
      end


      

      i-=7
    end


    #    i=0
    #    while i<str.length
    #      hexv=str[i,2]
    #      if "1B".eql?(hexv)
    #        i+=2
    #        hexv=str[i,2]
    #      end
    #
    #      unencoded+=hexv.to_i(16).chr
    #
    #      i+=2
    #    end


    return unencoded
  end



  def self.decode_ira(str)
    unencoded=""

    i=0
    while i<str.length
      hexv=str[i,2]
      if "1B".eql?(hexv)
        i+=2
        hexv=str[i,2]

        value=@extensiontable_rev[hexv.to_i(16)]
        value=" " if value.nil?
        unencoded+=value
      else
        val=@asciitable[hexv.to_i(16)]
        val=" " if val.nil?
        unencoded+=val
      end

      i+=2
    end

    return unencoded
  end




  def self.int2hex(i,max_nibbles=2)
    tmp=i.to_s(16).upcase
    if tmp.length%2!=0
      tmp="0"+tmp
    end

    remaining_nibbles=max_nibbles-tmp.length
    if remaining_nibbles>0
      tmp="0"*remaining_nibbles+tmp;
    end

    return tmp
  end



  # usado para construir um UCP duma string
  def self.parse_str(ustr)
    #puts "parse_str(#{ustr})"

    if ustr.nil?
      return nil
    end

    arr=ustr[(ustr.index(2.chr)+1)..-2].split("/")
    trn=arr[0]
    #puts "#{trn}"
    # length
    operation_type=arr[2]
    #puts "#{operation_type}"
    operation=arr[3]
    #puts "#{operation}"

    ucpmsg=nil

    if operation.eql?("01")
      if operation_type.eql?("O")
        # puts "parsing a ucp01"
        ucpmsg=Ucp01Operation.new(arr)
      elsif operation_type.eql?("R")
        # puts "parsing a result of a  ucp01"
        ucpmsg=Ucp01Result.new(arr)        
      end
    elsif operation.eql?("30")
      if operation_type.eql?("O")
        # puts "parsing a ucp30"
        ucpmsg=Ucp30Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp30"
        ucpmsg=Ucp30Result.new(arr)
      end
    elsif operation.eql?("31")
      if operation_type.eql?("O")
        #puts "parsing a ucp31"
        ucpmsg=Ucp31Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp31"
        ucpmsg=Ucp31Result.new(arr)
      end
    elsif operation.eql?("51")
      if operation_type.eql?("O")
        #puts "parsing a ucp51"
        ucpmsg=Ucp51Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp51"
        ucpmsg=Ucp51Result.new(arr)
      end
    elsif operation.eql?("52")
      if operation_type.eql?("O")
        #puts "parsing a ucp52"
        ucpmsg=Ucp52Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp52"
        ucpmsg=Ucp52Result.new(arr)
      end
    elsif operation.eql?("53")
      if operation_type.eql?("O")
        #puts "parsing a ucp53"
        ucpmsg=Ucp53Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp53"
        ucpmsg=Ucp53Result.new(arr)
      end
    elsif operation.eql?("54")
      if operation_type.eql?("O")
        #puts "parsing a ucp54"
        ucpmsg=Ucp54Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp54"
        ucpmsg=Ucp54Result.new(arr)
      end
    elsif operation.eql?("55")
      if operation_type.eql?("O")
        #puts "parsing a ucp55"
        ucpmsg=Ucp55Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp55"
        ucpmsg=Ucp55Result.new(arr)
      end
    elsif operation.eql?("56")
      if operation_type.eql?("O")
        #puts "parsing a ucp56"
        ucpmsg=Ucp56Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp56"
        ucpmsg=Ucp56Result.new(arr)
      end
    elsif operation.eql?("57")
      if operation_type.eql?("O")
        #puts "parsing a ucp57"
        ucpmsg=Ucp57Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp57"
        ucpmsg=Ucp57Result.new(arr)
      end
    elsif operation.eql?("58")
      if operation_type.eql?("O")
        #puts "parsing a ucp58"
        ucpmsg=Ucp58Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp58"
        ucpmsg=Ucp58Result.new(arr)
      end
    elsif operation.eql?("60")
      if operation_type.eql?("O")
        #puts "parsing a ucp60"
        ucpmsg=Ucp60Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp60"
        ucpmsg=Ucp60Result.new(arr)
      end
    elsif operation.eql?("61")
      if operation_type.eql?("O")
        #puts "parsing a ucp61"
        ucpmsg=Ucp61Operation.new(arr)
      elsif operation_type.eql?("R")
        #puts "parsing a result of a  ucp61"
        ucpmsg=Ucp61Result.new(arr)
      end
    end

    #ucpmsg.trn=trn
    return ucpmsg
  end




  # usado para construir uma resposta UCP a partir dum UCP
  def self.make_ucp_result(ucp)
    puts "make_ucp_result(#{ucp.to_s})"

    if ucp.nil?
      return nil
    end

    trn=ucp.trn
    #puts "#{trn}"
    # length
    operation_type=ucp.operation_type
    #puts "#{operation_type}"
    operation=ucp.operation
    #puts "#{operation}"

    ucpmsg=nil

    if operation.eql?("01")
      ucpmsg=Ucp01Result.new
    elsif operation.eql?("30")
      ucpmsg=Ucp30Result.new
    elsif operation.eql?("31")
      ucpmsg=Ucp31Result.new
    elsif operation.eql?("51")
      ucpmsg=Ucp51Result.new
    elsif operation.eql?("52")
      ucpmsg=Ucp52Result.new
    elsif operation.eql?("53")
      ucpmsg=Ucp53Result.new
    elsif operation.eql?("54")
      ucpmsg=Ucp54Result.new
    elsif operation.eql?("55")
      ucpmsg=Ucp55Result.new
    elsif operation.eql?("56")
      ucpmsg=Ucp56Result.new
    elsif operation.eql?("57")
      ucpmsg=Ucp57Result.new
    elsif operation.eql?("58")
      ucpmsg=Ucp58Result.new
    elsif operation.eql?("60")
      ucpmsg=Ucp60Result.new
    elsif operation.eql?("61")
      ucpmsg=Ucp61Result.new
    else
      return nil
    end

    ucpmsg.trn=trn
    return ucpmsg
  end

  def self.hex2str(hexstr)
    str=""
    hexstr.scan(/../).each { | tuple | str+=tuple.hex.chr }
    return str
  end

  def self.decode_ucp_msg(ucp)
    text=nil
    dcs=ucp.dcs.to_i(16)

    if (dcs & 0x0F == 0x01) || (dcs & 0x0F == 0x00)

      if ucp.operation.eql?("30")
        text=UCP.decode_ira(ucp.get_field(:amsg))
      else

        if ucp.operation.eql?("51") || ucp.operation.eql?("52") || ucp.operation.eql?("53")
          mt=ucp.get_field(:mt)
          if mt.eql?("2")
            # numeric message.. return it as it is
            text=ucp.get_field(:msg)
          elsif mt.eql?("3")
            text=UCP.decode_ira(ucp.get_field(:msg))
          else
            # unexpected "mt" value. return nil explicitely
            return nil
          end
        elsif ucp.operation.eql?("01")
          text=UCP.decode_ira(ucp.get_field(:msg))
        else
          # unexpected operation. return nil explicitely
          return nil
        end

      end
    elsif (dcs & 0x0F == 0x08) || (dcs & 0x0F == 0x09)
      str=UCP.hex2str(ucp.get_field(:msg))
      text=Iconv.iconv("utf-8","utf-16be",str).first
    else
      # cant decode text; unsupported DCS
      return nil
    end

    return text
  end

  def self.decode_ucp_oadc(ucp)
    otoa=nil
    oadc=ucp.get_field(:oadc)

    if ucp.is_a?(Ucp51Operation) || ucp.is_a?(Ucp52Operation) || ucp.is_a?(Ucp53Operation) || ucp.is_a?(Ucp54Operation) || ucp.is_a?(Ucp55Operation) || ucp.is_a?(Ucp56Operation) || ucp.is_a?(Ucp57Operation) || ucp.is_a?(Ucp58Operation)
      otoa=ucp.get_field(:otoa)
    end

    if otoa.nil? || otoa.eql?("1139")
      return oadc
    elsif otoa.eql?("5039")
      #useful_nibbles=oadc[0,2].to_i(16)
      return UCP.decode7bitgsm(oadc[2..-1])
    else
      #
    end

    # by default, return oadc
    return oadc
  end


  # initialize tables on first class reference, in fact when loading it
  initialize_ascii2ira()
  
end

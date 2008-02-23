#
#--
# Copyright (c) 2005-2008, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++
#

#
# "hecho en Costa Rica"
#
# john.mettraux@openwfe.org
#

require 'date'
#require 'parsedate'


module Rufus

    #TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    #
    # Returns the current time as an ISO date string
    #
    def Rufus.now

        to_iso8601_date(Time.new())
    end

    #
    # As the name implies.
    #
    def Rufus.to_iso8601_date (date)

        if date.kind_of? Float 
            date = to_datetime(Time.at(date))
        elsif date.kind_of? Time
            date = to_datetime(date)
        elsif not date.kind_of? Date
            date = DateTime.parse(date)
        end

        s = date.to_s # this is costly
        s[10] = " "

        s
    end

    #
    # the old method we used to generate our ISO datetime strings
    #
    def Rufus.time_to_iso8601_date (time)

        s = time.getutc().strftime(TIME_FORMAT)
        o = time.utc_offset / 3600
        o = o.to_s + "00"
        o = "0" + o if o.length < 4
        o = "+" + o unless o[0..1] == '-'

        s + " " + o.to_s
    end

    #
    # Returns a Ruby time
    #
    def Rufus.to_ruby_time (iso_date)

        DateTime.parse(iso_date)
    end

    #def Rufus.parse_date (date)
    #end

    #
    # equivalent to java.lang.System.currentTimeMillis()
    #
    def Rufus.current_time_millis

        (Time.new.to_f * 1000).to_i
    end

    #
    # turns a string like '1m10s' into a float like '70.0'
    #
    # w -> week
    # d -> day
    # h -> hour
    # m -> minute
    # s -> second
    # M -> month
    # y -> year
    # 'nada' -> millisecond
    #
    def Rufus.parse_time_string (string)

        string = string.strip

        index = -1
        result = 0.0

        number = ""

        loop do

            index = index + 1

            if index >= string.length
                if number.length > 0
                    result = result + (Float(number) / 1000.0)
                end
                break
            end

            c = string[index, 1]

            # TODO : investigate something better than this is_digit?

            if is_digit?(c)
                number = number + c
                next
            end

            value = Integer(number)
            number = ""

            multiplier = DURATIONS[c]

            raise "unknown time char '#{c}'" \
                if not multiplier

            result = result + (value * multiplier)
        end

        result
    end

    #
    # returns true if the character c is a digit
    #
    def Rufus.is_digit? (c)

        return false if not c.kind_of?(String)
        return false if c.length > 1
        (c >= "0" and c <= "9")
    end

    #
    # conversion methods between Date[Time] and Time

    #
    # Ruby Cookbook 1st edition p.111
    # http://www.oreilly.com/catalog/rubyckbk/
    # a must
    #

    #
    # converts a Time instance to a DateTime one
    #
    def Rufus.to_datetime (time)

        s = time.sec + Rational(time.usec, 10**6)
        o = Rational(time.utc_offset, 3600 * 24)

        begin

            DateTime.new(
                time.year, 
                time.month, 
                time.day, 
                time.hour, 
                time.min, 
                s, 
                o)

        rescue Exception => e

            #puts
            #puts OpenWFE::exception_to_s(e)
            #puts
            #puts \
            #    "\n Date.new() problem. Params :"+
            #    "\n....y:#{time.year} M:#{time.month} d:#{time.day} "+
            #    "h:#{time.hour} m:#{time.min} s:#{s} o:#{o}"

            DateTime.new(
                time.year, 
                time.month, 
                time.day, 
                time.hour, 
                time.min, 
                time.sec, 
                time.utc_offset)
        end
    end

    def Rufus.to_gm_time (dtime)

        to_ttime(dtime.new_offset, :gm)
    end

    def Rufus.to_local_time (dtime)

        to_ttime(dtime.new_offset(DateTime.now.offset-offset), :local)
    end

    def Rufus.to_ttime (d, method)

        usec = (d.sec_fraction * 3600 * 24 * (10**6)).to_i
        Time.send(method, d.year, d.month, d.day, d.hour, d.min, d.sec, usec)
    end

    protected

        DURATIONS = {
            "y" => 365 * 24 * 3600,
            "M" => 30 * 24 * 3600,
            "w" => 7 * 24 * 3600,
            "d" => 24 * 3600,
            "h" => 3600,
            "m" => 60,
            "s" => 1
        }

end


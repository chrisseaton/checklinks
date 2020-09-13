module Checklinks
  module Awesome
    # This module is code copied from awesome_bot by dkhamsing

    # The MIT License (MIT)
    #
    # Copyright (c) 2015 
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy
    # of this software and associated documentation files (the "Software"), to deal
    # in the Software without restriction, including without limitation the rights
    # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the Software is
    # furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.

    def self.links_filter(list)
      list.reject { |x| x.length < 9 }
        .map do |x|
          x.gsub(',','%2c').gsub(/'.*/, '').gsub(/,.*/, '')
        end
        .map do |x|
          if x.include? ')]'
            x.gsub /\)\].*/, ''
          elsif (x.scan(')').count == 1) && (x.scan('(').count == 1)
            x
          elsif (x.scan(')').count == 2) && (x.scan('(').count == 1)
            x.gsub(/\)\).*/, ')')
          elsif (x.scan(')').count > 0)
            if (x.include? 'wikipedia')
              if (x.scan(')').count >= 1) && (x.scan('(').count == 0)
                x.gsub(/\).*/, '')
              else
                x
              end
            else
              x.gsub(/\).*/, '')
            end
          elsif x.include? '[' # adoc
            x.gsub(/\[.*/, '')
          elsif x[-1]=='.' || x[-1]==':'
            x[0..-2]
          elsif x[-1]=='.'
            x[0..-2]
          elsif x[-3..-1]=='%2c'
            x[0..-4]
          else
            x
          end
        end
    end

    def self.net_status(url, timeout=30, head)
      require 'net/http'
      require 'openssl'
      require 'uri'

      uri = URI.parse url
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :open_timeout => timeout) do |http|
        ua = {'User-Agent' => 'checklinks'}
        if head
          request = Net::HTTP::Head.new(uri,ua)
        else
          request = Net::HTTP::Get.new(uri,ua)
        end

        if uri.userinfo
          auth_user, auth_pass = uri.userinfo.split(/:/)
          request.basic_auth auth_user, auth_pass
        end

        response = http.request request

        code = response.code==nil ? 200 : response.code.to_i

        headers = {}
        response.each do |k, v|
          headers[k] = v.force_encoding("utf-8")
        end

        # handle incomplete redirect
        loc = headers['location']
        unless loc.nil?
          loc_uri = URI.parse loc
          if loc_uri.scheme.nil?
            new_loc = uri.scheme + '://' + uri.host + loc
            headers['location'] = new_loc
          end
        end

        return [code, headers]
      end
    end
  end
end

# query hardware db for vendor name
#
# example usage:
#
# $vendor = cern_hwvendor([fqdn])

require "net/https"
require "uri"
require "timeout"
require "json"

module Puppet::Parser::Functions
  newfunction(:cern_hwvendor, :type => :rvalue) do |args|
    url = 'https://hwcollect.cern.ch:9000/hwinfo/_design/hwinfo/_view/hwhosts'
    client_hostname = false
    if args
      client_hostname = args[0]
    end

    unless client_hostname
      client_hostname = lookupvar('fqdn')
    end

    cert = OpenSSL::X509::Certificate.new(File.open(Puppet.settings[:hostcert]))
    key = OpenSSL::PKey::RSA.new(File.open(Puppet.settings[:hostprivkey]))
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.cert = cert
    http.key = key
    # maybe we should verify, but puppet occasionally seems to have problems with
    # ssl trust chains. So I'm chickening out
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)

    begin
      Timeout::timeout(5) {
        j = JSON.parse(http.request(request).body)
      }
    rescue Exception => e
      raise Puppet::ParseError, "Failed to contact hardware database #{e}"
    end
    # r.detect {|h| h["key"] == "voms116.cern.ch"}
    ans = j['rows'].detect {|h| h["key"] == client_hostname }
    if ans
      return ans["value"]["VENDOR"].downcase
    else
      return "NOT_FOUND"
    end
  end
end

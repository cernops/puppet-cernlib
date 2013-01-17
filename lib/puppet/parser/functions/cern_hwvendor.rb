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
    MISSING = "NOT_FOUND"
    cache_file = '/var/cache/hwdb_cache/cache'
    client_hostname = false
    if args.is_a?(Array) and not args.empty?
      client_hostname = args[0]
    end

    unless client_hostname
      client_hostname = lookupvar('fqdn')
    end

    j = nil
    unless File.exists?(cache_file)
      return MISSING
    end

    j = JSON.parse(File.open(cache_file).read)
    # r.detect {|h| h["key"] == "voms116.cern.ch"}
    unless j.is_a?(Hash) and j.has_key?("rows")
      raise Puppet::ParseError, "hardware database cache contains invalid data"
    end
    ans = j['rows'].detect {|h| h["key"] == client_hostname }
    if ans
      if ans["value"].has_key?("VENDOR")
        return ans["value"]["VENDOR"].downcase
      else
        return MISSING
      end
    else
      return MISSING
    end
  end
end

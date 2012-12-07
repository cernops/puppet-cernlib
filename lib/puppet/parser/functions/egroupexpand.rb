#egroup2users
#Recusive subroutine
#egroups = array of egroups
#conn = ldap connections
#recursion = true or false
#format = A string with a '%u' in it
#processed = a memory of groups we have allready processed.

def egroup2users(egroups,conn,recursion,format,processed)

  base     = 'OU=e-groups,OU=Workgroups,DC=cern,DC=ch'
  scope    = LDAP::LDAP_SCOPE_SUBTREE

  attr     = 'member'

  formatted = []
  egroups.each do |grp|
    # Don't process a group if we have allready done it.
    # in case group a contains b and b contains a.
    if processed.include?(grp)
      return formatted
    end
    processed.push(grp)

    result = []
    users = []
    filter   = "(&(objectClass=group)(CN=#{grp}))"
    begin
      conn.search(base, scope, filter, attr) { |entry|
        result = entry.vals(attr)
      }
    rescue LDAP::ResultError
    end || conn.perror("search")

    # We have ourselves an empty group.
    if ! result
      return users
    end

    # Process results
    result.each do |s|
      if s =~ /CN=(\S+),OU=Users,OU=Organic Units,DC=cern,DC=ch/
        users.push($1)
      elsif s =~ /CN=(\S+),OU=e-groups,OU=Workgroups,DC=cern,DC=ch/  && recursion == true
        users += egroup2users([$1],conn,recursion,format,processed)
      end
    end
    # Apply formatting, i.e replace occurences
    # of %u in the format with the username.

    users.each do |u|
      formatted.push(format.gsub(/%u/,u))
    end
  end
  return formatted
end


module Puppet::Parser::Functions
  newfunction(:egroupexpand, :type => :rvalue, :doc => <<-'EOS'
     Rerurns an array of usernames following the expansion of an
     egroup. Three arguments must be specified. The first is the egroup
     name. The second is format parameter, e.g. %u@CERN.CH.
     The third is true or false depending if you want to recurse
     egroups. Example:
       egroupexpand('ai-admins','%u@CERN.CH',true)
     will return an array ['straylen@CERN.CH','mccance@CERN.CH']
  EOS
  ) do |arguments|

    raise(Puppet::ParseError, "member(): Wrong number of arguments " +
        "given (#{arguments.size} instead of 3)") if arguments.size != 3

    egroup    = arguments[0]
    format    = arguments[1]
    recursion = arguments[2]

    require 'ldap'

    ldaphost = 'xldap.cern.ch'
    port     = 389

    conn = LDAP::Conn.new(ldaphost,port)
    conn.bind() || conn.perror('bind')

    users = egroup2users(egroup,conn,recursion,format,[])
    conn.unbind

    return users.uniq.sort

  end
end

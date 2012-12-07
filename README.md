CERN extensions for puppet
==========================

This is a collection of some CERN-specific puppet extensions, that don't belong
in any other particular module. Almost certainly not applicable externally.

Hardware vendor lookup
----------------------

Consult the CERN hardware database to find the vendor (or more accurately, the
company that is responsible for maintenance).

$vendor = cern_hwvendor()


Egroup expansion
----------------

Expand CERN egroups in manifests.

Rerurns an array of usernames following the expansion of an
     egroup. Three arguments must be specified. The first is the egroup
     name. The second is format parameter, e.g. %u@CERN.CH.
     The third is true or false depending if you want to recurse
     egroups. Example:
       egroupexpand('ai-admins','%u@CERN.CH',true)
     will return an array ['straylen@CERN.CH','mccance@CERN.CH']


Contact
-------

Ben Jones <ben.dylan.jones@cern.ch>

Copyright and License
---------------------

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

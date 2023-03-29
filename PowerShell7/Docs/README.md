# Scripts (API version 7.10):
## Modules: 
* dell.ddve.psm1
    * PowerShell7 module that covers basic interaction with the PowerProtect DD REST API
    * Functions
        * connect-restapi: method to request a bearer token
        * get-alerts: method to get alerts from a dd system
        * get-mtrees: method to get mtrees from a dd system
        * get-system: method to get dd system information
    * Tasks
        * Task-01: example query for system information
        * Task-02: example query for system alerts
        * Task-03: example query for mtrees
* dell.ddmc.psm1
    * PowerShell7 module that covers basic interaction with the PowerProtect DDMC REST API
    * Functions
        * connect-restapi: method to request a bearer token
        * get-datacenter: method to query for configured data centers
        * get-systempools: method to query for configured system pools
        * get-storageunits: method to query for storage units
        * get-recommendations: method to get recommended target for mobile storage unti migration
        * new-migration: method to start a new mobile storage unit migration
        * new-monitor: method to monitor a mobile storage unit migration
        * set-migrationcommit: method to commit the mobile storage unit migration
        * set-migrationcancel: method to release migration resources
    * Tasks
        * Task-04: example of mobile storage unit migration

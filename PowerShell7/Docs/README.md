# Scripts (API version 7.10):
## Modules: 
* dell.ddve.psm1
    * PowerShell7 module that covers basic interaction with the PowerProtect DD REST API
    * Functions
        * connect-ppdmapi: method to request a bearer token
        * disconnect-ppdmapi: method to destroy a bearer token
        * get-assets: method to query for assets based on filter
        * get-activities: method to query for activities based on filter
        * get-alerts: method to query for alerts based on filter
        * set-password: method of setting the ddboost user password, assigned to a protection policy, in PowerProtect Datamanager
        * get-policy: method to query for protection policies based on filter
        * set-policyassignment: method to batch assign, or unassign assets to a protection policy based on policy id, and assets id
        * get-sqlhosts: method to query for sql hosts based on filter
        * get-sqlcredentials: method to query for credentials
        * set-sqlcredentials: method to assign, or unassign credentials to a sql host
        * get-drserverconfig: method to the default dr recovery config
        * set-drserverconfig: method to update the default dr config
        * get-drserverhosts: method to get the dr server hosts
        * get-drserverbackups: method to get the dr server backups
        * new-drserverrecovery: method to start a new dr server recovery
    * Tasks
        * Task-01: example query for virtual machine assets
        * Task-02: example query for filesystem assets
        * Task-03: example query for mssql assets
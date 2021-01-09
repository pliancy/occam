# OCCAM - O365 Configuration Compliance Audit Manager

![O365 Configuration Compliance Audit Manager](logo.png)

----

OCCAM is an open-source toolkit for testing Office365 tenants against a set of security and compliance best practices. It is built for CSPs managing multiple tenants, though a future version will allow for use without CSP membership.

## Usage

:warning: Currently the O365 commands this module relies on are only supported on Windows

Download the Main branch and place the "occam" folder into the (default) `C:\Program Files\WindowsPowerShell\Modules` folder

```ps
Import-Module occam
Invoke-Occam
```

You will be prompted to enter your CSP-level User Principal Name and go through a modern auth workflow to log in. At that point, you will be prompted to select what tenents you wish to audit. Progress bars will indicate status, and final output is similar to the following example:

![Example Output Screenshot](example.png)

The output will also be saved to a CSV with an execution timestamp.

## Default Rules

A set of pre-made best practices have been bundled with this module. They include:

1. `Test-BasicAuth` - Checks to ensure that an authentication policy named "Block Basic Auth" is present
2. `Test-DefaultAuthPolicy` - Checks that the "Block Basic Auth" policy is set as the default for all users
3. `Test-PopImap` - Checks for any users that have POP or IMAP enabled and exports a CSV list of them
4. `Test-UnifiedAuditLogging` - Checks that Unified Audit Logging is enabled on the tenant
5. `Test-UserBasicAuth` - Checks for any users with Basic Authentication enabled and exports a CSV list of them

Additional rules can be added by inserting a compliant rule file into the `Rules` directory in the module. Rulesets are dynamically evaluated at run-time.

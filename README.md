# PowerShell script that can install itself as module

To create a PowerShell module, you normally have to create at least two files:
* a [script module](https://docs.microsoft.com/en-us/powershell/developer/module/how-to-write-a-powershell-script-module), 
 which is a Powershell script containing the advanced functions. Unlike a regular 
 Powershell script, it has to use the file suffix `.psm1`.
* a [module manifest](https://docs.microsoft.com/en-us/powershell/developer/module/how-to-write-a-powershell-module-manifest) 
 (`*.psd1`) that defines some metadata for the module.

If you have a NuGet repository, you can publish your module there to make it easily installable 
across your environment. But what if you do not have a NuGet repository you could publish the module 
to, but still want to make it easily installable for other users?

This repository shows how you can define a module in a _single_ `.ps1` file which can install itself 
as a PowerShell module.

When dot-sourced without arguments, the script will make the advanced functions defined in the script
(here: `Invoke-TemplateTest`) available to the current session:

```
PS> . .\Install-Template.ps1

Name                           Value
----                           -----
ModuleVersion                  1.0
FunctionsToExport              {Invoke-TemplateTest}
RootModule                     JP.TemplateModule.psm1

Advanced functions added to current session.
Use -Install to add functions permanenently.


PS> Invoke-TemplateTest
This is a test function
```

If you run `.\Install-Template.ps1 -Install CurrentUser`, the script generates a `.psm1` and `psd1` file off 
of itself and saves them to `[MyDocuments]\WindowsPowerShell\Modules\JP.TemplateModule`. This causes 
the advanced functions to permanently become available for the current user:

```
PS > .\Install-Template.ps1 -Install CurrentUser

Name                           Value
----                           -----
ModuleVersion                  1.0
FunctionsToExport              {Invoke-TemplateTest}
RootModule                     JP.TemplateModule.psm1

Advanced functions added to current session.
Advanced functions installed to C:\Users\jpassing\Documents\WindowsPowerShell\Modules\
```

In a new session:
```
PS> Invoke-TemplateTest
This is a test function
```

Finally, if you run `.\Install-Template.ps1 -Install LocalMachine`,  the script generates a 
`.psm1` and `psd1` file off of itself and saves them to 
`[ProgramFiles]\WindowsPowerShell\Modules\JP.TemplateModule`, causing the advanced functions 
to become visible to everyone.

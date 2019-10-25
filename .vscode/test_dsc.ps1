Configuration Dsc_withnewsite

{
    Import-DscResource -Module PSDesiredStateConfiguration, xWebAdministration

    Node 'localhost' {
        WindowsFeature 'InstallIIS' {
            Ensure = 'Present'
            Name   = 'Web-Server'
        }
        xWebSite 'TestSite' {
            Name            = 'TestSite'
            BindingInfo     = @( MSFT_xWebBindingInformation {
                    Protocol = 'HTTP'
                    Port     = 8080
                }
            )
            PhysicalPath    = 'C:\inetpub\wwwroot'
            ApplicationPool = 'TestAppPool'
            DependsOn       = '[xWebAppPool]TestAppPool'
        }
        xWebAppPool 'TestAppPool' {

            Name = 'TestAppPool'

        }
        File WebsiteContent {
            Ensure          = 'Present'
            DestinationPath = 'c:\inetpub\wwwroot\index.htm'
            Contents = '<head></head>
            <body>
            <p>Hello World!</p>
            </body>'
        }

    }

}
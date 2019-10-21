Function Get-Weather {
    [CmdletBinding()]
              
    # Parameters used in this function
    Param
    (
        [Parameter(Position=0, Mandatory = $true, HelpMessage="Provide city name", ValueFromPipeline = $true)]
        #[ValidateLength(5,10)]
        #[string]
        $City,

        [Parameter(Position=1, Mandatory = $true, HelpMessage="Provide the date in format yyyy/mm/dd", ValueFromPipeline = $true)]
        #[ValidateLength(8,10)]
        #[string]
        $Inputday
     
    )
     $Day = $Inputday -replace "(\d{2})\/(\d{2})\/(\d{4})", '$3/$2/$1'
    

    If ([string]::IsNullOrWhiteSpace($City)) {
        $City="Minsk"
        Write-Host "City = Minsk"}
    If ([string]::IsNullOrWhiteSpace($Day))  {
        $Day=Get-Date -Format "yyyy/MM/dd"
        Write-Host "Day  =" (Get-Date -Format "yyyy/MM/dd")}  
    
    $errmsg = "The name of city or date are incorrect. Please enter the valid name of the city and check that the date is in following format DD/MM/YYYY or YYYY/MM/DD"
                         
    $WeatherResults = @()
    $Uri = "https://www.metaweather.com/api/location/search/?query=" + "$City"
     
    Try
    {
        $Location = Invoke-WebRequest -URI $Uri 
    }
    Catch
    {
        #$_.Exception.Message
        write-host "$errmsg"
        Break
    }
 
    If($Location)
    {
        $Location = $Location.content | ConvertFrom-Json
        $Woeid = $Location.woeid
        $WeatherLink = "https://www.metaweather.com/api/location/" + $Woeid + "/" + $day + "/"
     
        Try
        {
            $Weather = Invoke-WebRequest -URI $WeatherLink
        }
        Catch
        {
           #$_.Exception.Message
           write-host "$errmsg"
            Break
        }
     
        If($Weather)
        {
            $Weather = $Weather.content  | ConvertFrom-Json
            $Results = $Weather[0]
 
            $Object = New-Object PSObject -Property @{
     
                State                  = $Results.weather_state_name
                Date                   = $Results.created
                "Temperature(Min)"     = $Results.min_temp  
                "Temperature(Max)"     = $Results.max_temp          
                WindSpeed              = $Results.wind_speed
                WindDirection          = $Results.wind_direction_compass
                AirPressure            = $Results.air_pressure
                Predictability         = $Results.predictability     
            }
 
                $WeatherResults += $Object
        }
    }
 
    If($WeatherResults)
    {
        $minT = [math]::Round($Object.'Temperature(Min)', 0)
        $maxT = [math]::Round($Object.'Temperature(Max)', 0)
        Write-Host "`nThe Weather in " -ForegroundColor Green -NoNewline
        Write-Host "$City on $Day is: min $minT and max $maxT degrees" -ForegroundColor Green -NoNewline
 
        # $WeatherResults | select State,"Temperature(Min)","Temperature(Max)",WindSpeed,WindDirection,AirPressure,Predictability #,date
    }
 
}




<#
   $errorAction = $PSBoundParameters["ErrorAction"]
    if(-not $errorAction){
        $errorAction = $ErrorActionPreference


   $Location = Invoke-WebRequest -URI $Uri -ErrorAction $errorAction
    write "SomeText"


$ErrorActionPreference = 'Stop'
test1

$ErrorActionPreference = 'continue'
test1 -ErrorAction Stop
#>

function Get-BIRCompanyData {
    <#
.Synopsis
   Get Company data by Vat Registration Number (NIP) from GUS BIR API (https://api.stat.gov.pl/)

.DESCRIPTION
   Get Company data by Vat Registration Number (NIP) from GUS BIR API (https://api.stat.gov.pl/)
   BIR version 1.1
   Url of API: https://wyszukiwarkaregon.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc
   Action: DaneSzukajPodmioty

.PARAMETER VATNumber
    Polish Vat Registration Number.
    All non-digit characters are removed
        Example: PL123-45-67-890 => 1234567890
    Can be a single number or an array of number
        Example: $Vat = 1234567890, 2345678901
        Get-BIRCompanyData -VATNumber $Vat -TestMode
        (returns two records)

.PARAMETER Key
    API Key.
    To get an API key you need to register -> https://api.stat.gov.pl/Home/RegonApi#menu2
.PARAMETER TestMode
    Runs query in test mode using URL https://wyszukiwarkaregontest.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc and test API key

.PARAMETER DelayBetweenRequests
    Delay between requests in ms. Current limitations of API
    Info about current limitation in requests -> https://api.stat.gov.pl/Home/RegonApi#menu3
.EXAMPLE
   Get-BIRCompanyData -VATNumber 1234567890 -TestMode

   Runs query in test mode
.EXAMPLE
    Get-BIRCompanyData -VATNumber 1234567890 -Key YourUniqueKey
.EXAMPLE
    Get-BIRCompanyData -VATNumber 1234567890, 2345678910 -Key YourUniqueKey
.LINK
    https://api.stat.gov.pl/Home/RegonApi
#>
    [cmdletbinding(
        DefaultParameterSetName = 'Default'
    )]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        $Key,
        [Parameter(Mandatory = $true)]
        [string[]]$VATNumber,
        [Parameter(Mandatory = $true, ParameterSetName = 'TestMode')]
        [switch]$TestMode,
        [int]$DelayBetweenRequests = 350
    )
    if ($TestMode) {
        $url = "https://wyszukiwarkaregontest.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc"
        $Key = 'abcde12345abcde12345'
    } else {
        $url = "https://wyszukiwarkaregon.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc"
    }
    Write-Debug "URL: $url"
    #region Functions
    function BIR-Login {
        param(
            $url, $key
        )
        $requestXML = "<soap:Envelope xmlns:soap=`"http://www.w3.org/2003/05/soap-envelope`" xmlns:ns=`"http://CIS/BIR/PUBL/2014/07`">
        <soap:Header xmlns:wsa=`"http://www.w3.org/2005/08/addressing`">
        <wsa:To>$url</wsa:To>
        <wsa:Action>http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj</wsa:Action>
        </soap:Header>
        <soap:Body>
        <ns:Zaloguj>
        <ns:pKluczUzytkownika>$key</ns:pKluczUzytkownika>
        </ns:Zaloguj>
        </soap:Body>
        </soap:Envelope>
        "
        try {
            $loginReq = Write-Reqest -url $url -requestXML $requestXML
            $response = Get-Response -Request $loginReq
            $sid = Get-LoginResponse -response $response
            $sid
        } catch {
            throw $_
        }
        Write-Verbose "Login to service. Returned sid $sid"
    }
    function BIR-Logoff {
        param(
            $url, $sid
        )
        $requestXML = "<soap:Envelope xmlns:soap=`"http://www.w3.org/2003/05/soap-envelope`" xmlns:ns=`"http://CIS/BIR/PUBL/2014/07`">
        <soap:Header xmlns:wsa=`"http://www.w3.org/2005/08/addressing`">
        <wsa:To>$url</wsa:To>
        <wsa:Action>http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj</wsa:Action>
        </soap:Header>
        <soap:Body>
        <ns:Wyloguj>
        <ns:pIdentyfikatorSesji>$sid</ns:pIdentyfikatorSesji>
        </ns:Wyloguj>
        </soap:Body>
        </soap:Envelope>
        "
        try {
            $logoutReq = Write-Reqest -url $url -requestXML $requestXML
            $response = Get-Response -Request $logoutReq
            Get-LogoutResponse -response $response
        } catch {
            throw $_
        }

    }
    function Get-CompanyFromBIR {
        param($NIP, $url, $sid)
        $requestXML = "<soap:Envelope xmlns:soap=`"http://www.w3.org/2003/05/soap-envelope`" xmlns:ns=`"http://CIS/BIR/PUBL/2014/07`" xmlns:dat=`"http://CIS/BIR/PUBL/2014/07/DataContract`">
    <soap:Header xmlns:wsa=`"http://www.w3.org/2005/08/addressing`">
    <wsa:To>$url</wsa:To>
    <wsa:Action>http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty</wsa:Action>
    </soap:Header>
    <soap:Body>
    <ns:DaneSzukajPodmioty>
    <ns:pParametryWyszukiwania>
    <dat:Nip>$NIP</dat:Nip>
    </ns:pParametryWyszukiwania>
    </ns:DaneSzukajPodmioty>
    </soap:Body>
    </soap:Envelope>
    "
        try {
            $searchReq = Write-Reqest -url $url -requestXML $requestXML -Sid $sid
            $response = Get-Response -Request $searchReq
            Get-CompanyResponse -response $response
        } catch {
            throw $_
        }

    }
    function Write-Reqest {
        param($url, $requestXML, $sid)
        try {
            $Request = [System.Net.HttpWebRequest]::Create($url)
            $Request.Method = 'POST';
            $Request.ContentType = 'application/soap+xml; charset=utf-8'
            if ($sid) {
                $Request.Headers.Add('sid', $sid)
            }
            $Request.Timeout = 10000
            $streamwriter = [System.IO.StreamWriter]::new($Request.GetRequestStream(), [System.Text.Encoding]::ASCII)
            $streamwriter.Write($requestXML)
            $streamwriter.Close()
            $Request
        } catch {
            throw $_
        }
    }
    function Get-Response {
        param($Request)
        try {
            $response = $Request.GetResponse()
            $stream = $response.GetResponseStream()
            $sr = new-object System.IO.StreamReader $stream
            $result = $sr.ReadToEnd()
            $result
        } catch {
            throw $_
        }

    }
    function Get-LoginResponse {
        param($response)
        try {
            ($response -replace '`n') -match '<s:Envelope.*<\/s:Envelope>' | out-null
            [xml]$xml = $matches[0]
            $sid = $xml.Envelope.Body.ZalogujResponse.ZalogujResult
            $sid
        } catch {
            throw $_
        }
    }
    function Get-LogoutResponse {
        param($response)
        try {
            ($response -replace '`n') -match '<s:Envelope.*<\/s:Envelope>' | out-null
            [xml]$xml = $matches[0]
            $xml.Envelope.Body.WylogujResponse.WylogujResult
        } catch {
            throw $_
        }
    }
    Function Get-CompanyResponse {
        param($response)
        try {
            ($response -replace '\n') -match '<s:Envelope.*<\/s:Envelope>' | out-null
            [xml]$xml = $matches[0]
            [xml]$CompanyData = [xml]$xml.Envelope.Body.DaneSzukajPodmiotyResponse.DaneSzukajPodmiotyResult
            $CompanyData.root.dane
        } catch {
            throw $_
        }
    }

    #endregion functions

    $sid = BIR-Login -url $url -key $key
    if (!$sid) {
        throw "Login failed"
    }

    $resultsBIR = @()
    $i = 0
    $resultsBIR = foreach ($NIP in $VATNumber) {
        $NIP = $NIP -replace '\D'
        Write-Verbose $NIP
        $resBir = Get-CompanyFromBIR -NIP $NIP -url $url -sid $sid
        $resBir
        $i++
        if ($i -lt $VATNumber.count) {
            Start-Sleep -Milliseconds $DelayBetweenRequests
        }

    }
    $resultsBIR
    BIR-Logoff -url $url -sid $sid | Out-Null
}

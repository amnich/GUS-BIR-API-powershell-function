# GUS BIR API powershell function

Powershell function to get company data by Vat Registration Number (NIP) from Polish GUS BIR API ([https://api.stat.gov.pl/](https://api.stat.gov.pl/))

Created for BIR version 1.1.

Used actions: Zaloguj, Wyloguj, DaneSzukajPodmioty

Url of API: [https://wyszukiwarkaregon.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc](https://wyszukiwarkaregon.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc)

You need to register at [GUS](https://api.stat.gov.pl/) to get your API key.

```powershell
PS C:\> Get-BIRCompanyData -VATNumber 5270103391 -Key 'YourPrivateKey'

Regon                       : 010016565
Nip                         : 5270103391
StatusNip                   : 
Nazwa                       : MICROSOFT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
Wojewodztwo                 : MAZOWIECKIE
Powiat                      : m. st. Warszawa
Gmina                       : Włochy
Miejscowosc                 : Warszawa
KodPocztowy                 : 02-222
Ulica                       : Aleje Jerozolimskie
NrNieruchomosci             : 195A
NrLokalu                    : 
Typ                         : P
SilosID                     : 6
DataZakonczeniaDzialalnosci :   
```
#### PARAMETER VATNumber

  Polish Vat Registration Number. 
  All non-digit characters are removed
      Example: PL123-45-67-890 => 1234567890
  Can be a single number or an array of number
      Example: $Vat = 1234567890, 2345678901
      Get-BIRCompanyData -VATNumber $Vat -TestMode
      (returns two records)

#### PARAMETER Key

  API Key.
  
  To get an API key you need to register -> https://api.stat.gov.pl/Home/RegonApi#menu2
    
#### PARAMETER TestMode

  Runs query in test mode using URL https://wyszukiwarkaregontest.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc and test API key

#### PARAMETER DelayBetweenRequests

  Delay between requests in ms. 
  Info about current limitation in requests -> https://api.stat.gov.pl/Home/RegonApi#menu3
    
#### EXAMPLE 1
Runs query in test mode  
```powershell
PS C:\> Get-BIRCompanyData -VATNumber 5270103391 -TestMode

Regon                       : 010016565
Nip                         : 5270103391
StatusNip                   : 
Nazwa                       : MICROSOFT SPÓŁKA Z O.O.
Wojewodztwo                 : MAZOWIECKIE
Powiat                      : m. st. Warszawa
Gmina                       : Włochy
Miejscowosc                 : Warszawa
KodPocztowy                 : 02-222
Ulica                       : ul. Test-Krucza
NrNieruchomosci             : 195A
NrLokalu                    : 
Typ                         : P
SilosID                     : 6
DataZakonczeniaDzialalnosci : 
MiejscowoscPoczty           : Warszawa
```
   
#### EXAMPLE 2
```powershell
PS C:\> Get-BIRCompanyData -VATNumber 5270103391 -Key 'YourPrivateKey'

Regon                       : 010016565
Nip                         : 5270103391
StatusNip                   : 
Nazwa                       : MICROSOFT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
Wojewodztwo                 : MAZOWIECKIE
Powiat                      : m. st. Warszawa
Gmina                       : Włochy
Miejscowosc                 : Warszawa
KodPocztowy                 : 02-222
Ulica                       : Aleje Jerozolimskie
NrNieruchomosci             : 195A
NrLokalu                    : 
Typ                         : P
SilosID                     : 6
DataZakonczeniaDzialalnosci :   
```
#### EXAMPLE 3
```powershell
PS C:\> Get-BIRCompanyData -VATNumber 5270103391, 525-23-44-078 -TestMode

Regon                       : 010016565
Nip                         : 5270103391
StatusNip                   : 
Nazwa                       : MICROSOFT SPÓŁKA Z O.O.
Wojewodztwo                 : MAZOWIECKIE
Powiat                      : m. st. Warszawa
Gmina                       : Włochy
Miejscowosc                 : Warszawa
KodPocztowy                 : 02-222
Ulica                       : ul. Test-Krucza
NrNieruchomosci             : 195A
NrLokalu                    : 
Typ                         : P
SilosID                     : 6
DataZakonczeniaDzialalnosci : 
MiejscowoscPoczty           : Warszawa

Regon                       : 140182840
Nip                         : 5252344078
StatusNip                   : 
Nazwa                       : GOOGLE POLAND SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
Wojewodztwo                 : MAZOWIECKIE
Powiat                      : m. st. Warszawa
Gmina                       : Śródmieście
Miejscowosc                 : Warszawa
KodPocztowy                 : 00-113
Ulica                       : ul. Test-Krucza
NrNieruchomosci             : 53
NrLokalu                    : 
Typ                         : P
SilosID                     : 6
DataZakonczeniaDzialalnosci : 
MiejscowoscPoczty           : Warszawa
```
#### LINK
  [https://api.stat.gov.pl/Home/RegonApi](https://api.stat.gov.pl/Home/RegonApi)

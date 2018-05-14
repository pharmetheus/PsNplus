# PsNplus
PsNplus is developed and maintained by [Pharmetheus](http://pharmetheus.com/).
It is an add-on package for [PsN](https://uupharmacometrics.github.io/PsN/).
 
PsNplus is a free and open source software: you can redistribute it and/or modify it
under the terms of the [GNU General Public License](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version.

## Installation
PsNplus officially supports only Linux. Mac and Windows may work, but are not tested.

1. PsN version 4.7.0 or later must be installed and tested before installation of PsNplus. If you choose dynamic detection of PsN library, PsN must also be in your path.
2. Download the zipped tar-ball of the release and unpack it in a suitable location.
3. Add the bin sub-directory to your path. 
4. - If you choose dynamic detection of PsN library, you are done.
   - If you instead choose the static (faster) method, open file PsN_library.pm in the lib subdirectory and set
```   
my $useStaticPsNversion = 0;
```
and
```
$psnlib = "/path/to/existing/psn/lib/directory";
```

The version number of PsNplus and the full path to the executed script is printed in version_and_option_info.txt of each run directory, together with the version number of the PsN library used. File meta.yaml does not contain the PsNplus information.

# IDE setup for MASM
Steps to configure Visual Studio for MASM programming.

Copyright © 2021 by Arthurits Ltd. No commercial nor profit use allowed. This software is provided only for personal and not-for-profit use.
Download latest release: [![GitHub release (latest by date)](https://img.shields.io/github/v/release/arthurits/AssemblySnippets)](https://github.com/arthurits/AssemblySnippets/releases)

## Steps (work in progress)
* Install Visual Studio.
* Make sure to install "Desktop development with C++".
![Screenshot](/IDE%20Setup/Media/Screenshot01.png?raw=true "Install desktop develpment with C++")
* Create a new C++ empty project.
![Screenshot](/IDE%20Setup/Media/Screenshot02.png?raw=true "Empty project")
* Once inside Visual Studio, right click on the project just created, select **Build Dependencies**->**Build Customizations...** from the floating menu (or go to menu **Project**->**Build Customizations...**), and check the `masm` option.
![Screenshot](/IDE%20Setup/Media/Screenshot03.png?raw=true "Target .masm")

### Optional: set directories
For the following options, either right click on the project and select **Properties** from the floating menu or go to menu **Project**->**Properties**.
![Screenshot](/IDE%20Setup/Media/Screenshot04-A.png?raw=true "Right click to select project properties")
![Screenshot](/IDE%20Setup/Media/Screenshot04-B.png?raw=true "Select menu project properties")
<img src="https://github.com/arthurits/AssemblySnippets/blob/master/IDE%20Setup/Media/Screenshot04-A.png?" width=50% height=50%>
<img src="https://github.com/arthurits/AssemblySnippets/blob/master/IDE%20Setup/Media/Screenshot04-B.png?" width=50% height=50%>
* Set the output and the intermediate directories. Go to **Configuration Properties**->**General** and set the paths according to your own preferences.
![Screenshot](/IDE%20Setup/Media/Screenshot05.png?raw=true "Output directories")


### Linker properties
For the following options, either right click on the project and select **Propertie**s from the floating menu or go to menu **Project**->**Properties**.
* Disable incremental link in **only in Release** configurarion. Go to **Configuration Properties**->**Linker**->**General**.
* Enable optimizations **only in Release** configuration. Go to **Configuration Properties**->**Linker**->**Optimization**
* Define the programm's entry point for `All Configurations`. Go to **Configuration Properties**->**Linker**->**Advanced**.
![Screenshot](/IDE%20Setup/Media/Screenshot08.png?raw=true "Define entry point")

(while there, make sure the **Target Machine** is set to your desired architecture).
* Set the subsystem to either `Console` or `Windows`. Go to **Configuration Properties**->**Linker**->**System**.
![Screenshot](/IDE%20Setup/Media/Screenshot09.png?raw=true "Linker subsystem")

### Macro assembler properties
For the following options, either right click on the project and select **Propertie**s from the floating menu or go to menu **Project**->**Properties**.
* Preserve Identifier Case (/Cp flag). Go to **Configuration Properties**->**Microsoft Macro Assembler**->**General**.
![Screenshot](/IDE%20Setup/Media/Screenshot10-Debug.png?raw=true "Preserve identifier case")
* Generate debug information (/Zi flag) **only for Debug** configuration.
![Screenshot](/IDE%20Setup/Media/Screenshot11-Debug.png?raw=true "Generate debug information")
![Screenshot](/IDE%20Setup/Media/Screenshot11-Release.png?raw=true "Don't generate debug information in release mode")
* Enable flags /Sa and /Sn (**only in Debug** configuration) and set the listing file path. Go to **Configuration Properties**->**Microsoft Macro Assembler**->**General** set the flags (make sure they are disabled for `Release`) and type the desired path.
![Screenshot](/IDE%20Setup/Media/Screenshot12-Debug.png?raw=true "Listing options in debug mode")
![Screenshot](/IDE%20Setup/Media/Screenshot12-Release.png?raw=true "Listing options in release mode")
* 

### Optional: set external dependencies
In case your project relies on external dependencies (such as `Irvine32.lib` or `masm32 SDK`), these three steps should be followed accordingly.
* Add the SDK or library folder path (/LIBPATH flag) at `Additional Library Directories` in **Configuration Properties**->**Linker**->**General**.
![Screenshot](/IDE%20Setup/Media/Screenshot13.png?raw=true "Additional library directories")
* Add the library files (*.lib) at `Additional Dependencies` in **Configuration Properties**->**Linker**->**Input**.
![Screenshot](/IDE%20Setup/Media/Screenshot14.png?raw=true "Additional dependencies")
* Add folder paths (/I flag) at `Include Paths` in **Configuration Properties**->**Microsoft Macro Assembler**->**General**.
![Screenshot](/IDE%20Setup/Media/Screenshot15.png?raw=true "Include paths")

## License
Free for personal and not-for-profit use.
No commercial use allowed.

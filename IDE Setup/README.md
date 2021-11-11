# IDE setup for MASM
Steps to configure Visual Studio for MASM programming.

Copyright © 2021 by Arthurits Ltd. No commercial nor profit use allowed. This software is provided only for personal and not-for-profit use.
Download latest release: [![GitHub release (latest by date)](https://img.shields.io/github/v/release/arthurits/AssemblySnippets)](https://github.com/arthurits/AssemblySnippets/releases)

## General steps
* Install Visual Studio.
* Make sure to install "Desktop development with C++".
![Screenshot](/IDE%20Setup/Media/Screenshot01.png?raw=true "Install desktop develpment with C++")
* Create a new C++ empty project.
![Screenshot](/IDE%20Setup/Media/Screenshot02.png?raw=true "Empty project")
* Once inside Visual Studio, right click on the project just created, select **Build Dependencies**->**Build Customizations...** from the floating menu (or go to menu **Project**->**Build Customizations...**), and check the `masm` option.
![Screenshot](/IDE%20Setup/Media/Screenshot03.png?raw=true "Target .masm")
* *Optional*: Associate `asm` extension. Go to menu **Tools**->**Text Editor**->**File Extension**.
![Screenshot](/IDE%20Setup/Media/Screenshot00.png?raw=true "Associate asm extension")
### Optional: set directories
For the following options, either right click on the project and select **Properties** from the floating menu or go to menu **Project**->**Properties**.

<img src="/IDE%20Setup/Media/Screenshot04-A.png" alt="Right click to select project properties" width=51% > <img src="https://github.com/arthurits/AssemblySnippets/blob/master/IDE%20Setup/Media/Screenshot04-B.png" alt="Select menu project properties" width=48% >
* Set the output and the intermediate directories. Go to **Configuration Properties**->**General** and set the paths according to your own preferences.

![Screenshot](/IDE%20Setup/Media/Screenshot05.png?raw=true "Output directories")


### Linker properties
For the following options, either right click on the project and select **Propertie**s from the floating menu or go to menu **Project**->**Properties**.

* Disable incremental link in **only in Release** configurarion. Go to **Configuration Properties**->**Linker**->**General**.

![Screenshot](/IDE%20Setup/Media/Screenshot06.png?raw=true "Disable incremental link")

* Enable optimizations **only in Release** configuration. Go to **Configuration Properties**->**Linker**->**Optimization**.

![Screenshot](/IDE%20Setup/Media/Screenshot07.png?raw=true "Enable optimizations")

* Define the programm's entry point for `All Configurations`. Go to **Configuration Properties**->**Linker**->**Advanced**.

![Screenshot](/IDE%20Setup/Media/Screenshot08.png?raw=true "Define entry point")

(while there, make sure the **Target Machine** is set to your desired architecture).

* Set the subsystem to either `Console` or `Windows`. Go to **Configuration Properties**->**Linker**->**System**.

![Screenshot](/IDE%20Setup/Media/Screenshot09.png?raw=true "Linker subsystem")

* Safe exception handlers (/SAFESEH flag): either allow or disable the flag both at **Configuration Properties**->**Linker**->**Advanced** and **Configuration Properties**->**Microsoft Macro Assembler**->**Advanced**

<img src="/IDE%20Setup/Media/Screenshot16.png" alt="Linker safe exception handlers" width=49% > <img src="https://github.com/arthurits/AssemblySnippets/blob/master/IDE%20Setup/Media/Screenshot17.png" alt="MASM safe exception handlers" width=49% >

### Macro assembler properties
For the following options, either right click on the project and select **Propertie**s from the floating menu or go to menu **Project**->**Properties**.
* Preserve Identifier Case (/Cp flag). Go to **Configuration Properties**->**Microsoft Macro Assembler**->**General**.
![Screenshot](/IDE%20Setup/Media/Screenshot10.png?raw=true "Preserve identifier case")
* Generate debug information (/Zi flag) **only for Debug** configuration.

<img src="/IDE%20Setup/Media/Screenshot11-Debug.png" alt="Generate debug information" width=49% > <img src="/IDE%20Setup/Media/Screenshot11-Release.png" alt="Don't generate debug information in release mode" width=49% >
* Enable flags /Sa and /Sn (**only in Debug** configuration) and set the listing file path. Go to **Configuration Properties**->**Microsoft Macro Assembler**->**General** set the flags (make sure they are disabled for `Release`) and type the desired path.

<img src="/IDE%20Setup/Media/Screenshot12-Debug.png" alt="Listing options in debug mode" width=49% > <img src="/IDE%20Setup/Media/Screenshot12-Release.png" alt="Listing options in release mode" width=49% >

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

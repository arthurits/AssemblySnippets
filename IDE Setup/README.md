# IDE setup for MASM
Steps to configure Visual Studio for MASM programming.

Copyright © 2021 by Arthurits Ltd. No commercial nor profit use allowed. This software is provided only for personal and not-for-profit use.
Download latest release: [![GitHub release (latest by date)](https://img.shields.io/github/v/release/arthurits/AssemblySnippets)](https://github.com/arthurits/AssemblySnippets/releases)

## Steps (work in progress)
* Install Visual Studio.
* Make sure to install "Desktop development with C++".
* Create a new C++ empty project.
![Screenshot](/IDE%20Setup/Media/Screenshot02.png?raw=true "Empty project")
* Select the project just created, right click on it (or go to menu **Project**->**Build Customizations...**) and check the `masm` option.
![Screenshot](/IDE%20Setup/Media/Screenshot03.png?raw=true "Target .masm")

### Set directories (optional)
For the following options, either right click on the project and select **Propertie**s from the floating menu or go to menu **Project**->**Properties**.
* Set the input, output and intermediate directories. Go to **Configuration Properties**->**General**.

### Linker properties
For the following options, either right click on the project and select **Propertie**s from the floating menu or go to menu **Project**->**Properties**.
* Define the programm's entry point for `All Configurations`. Go to **Configuration Properties**->**Linker**->**Advanced**.
![Screenshot](/IDE%20Setup/Media/Screenshot05.png?raw=true "Define entry point")

(while there, make sure the **Target Machine** is set to your desired program architecture).
* Set the subsystem to either `Console` or `Windows`. Go to **Configuration Properties**->**Linker**->**System**.
![Screenshot](/IDE%20Setup/Media/Screenshot06.png?raw=true "Linker subsystem")

### Macro assembler properties
For the following options, either right click on the project and select **Propertie**s from the floating menu or go to menu **Project**->**Properties**.
* Preserve Identifier Case (/Cp flag). Go to **Configuration Properties**->**Microsoft Macro Assembler**->**General**.
![Screenshot](/IDE%20Setup/Media/Screenshot07-Debug.png?raw=true "Preserve identifier case")
* Generate debug information (/Zi flag) **only for Debug** configuration.
![Screenshot](/IDE%20Setup/Media/Screenshot07-Debug.png?raw=true "Generate debug information")
![Screenshot](/IDE%20Setup/Media/Screenshot07-Release.png?raw=true "Don't generate debug information in release mode")

## License
Free for personal and not-for-profit use.
No commercial use allowed.

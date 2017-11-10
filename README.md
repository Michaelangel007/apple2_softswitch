# Apple 2 Soft Switch

Inspired by Anthony's program over in [c.s.a2](https://groups.google.com/d/msg/comp.sys.apple2/knWRdHp9ZTc/TWV5ZkyTCQAJ) here is a Applesoft BASIC program to display a memory map and limited soft switches.

![Screenshot Desc](pics/screenshot_desc.png)
![Screenshot Addr](pics/screenshot_addr.png)


# Commands

* ESC = exit
* SPC = toggle status lines to show description / soft-switch addresss

NOTE: The IO soft switch address don't exactly match the hardware switches due to:

a) some are contiguous
b) some require multiple locations to activate (i.e. TEXT/GR and Lo-Res/Hi-Res)


# Future Versions?

Removing the `RW` columns gives us a little more space on the right
Mock-up

```
v4    ___READ___ __WRITE___   
$FFFF|    ROM   |    ROM   |   C088 BANK2
$E000|__________|__________|  /C081 HRAMWRT
     |    ROM   |    ROM   | / C080 HRAMRD
$D000|__________|__________|/  C057 HIRES
     :__________:__________:   C055 PAGE2
$BFFF|    AUX   |    AUX   |\  C008 ALTZP
$6000|__________|__________| \ C004 RAMWRT
     |    AUX   |    AUX   |  \C002 RAMRD
$4000|__________|__________|   C000 80STORE
```


# History

## Ver 4

* Version number now shown in top left
* Fixed 80STORE=1 display for HGR1 and TEXT1
* Removed most odd addresses in the main 48 KB as they were cluttering up the display too much.


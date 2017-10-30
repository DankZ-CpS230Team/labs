@echo off

rem Assuming the normal installation path for Visual C++ 2015...
call "\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"

nasm -f win32 -g uprintf.asm || goto :eof

cl /c /Zi uhelpers.c || goto :eof

lib /out:uprintf.lib uprintf.obj uhelpers.obj || goto :eof

cl /Zi demo_uprintf.c uprintf.lib || goto :eof

echo OK

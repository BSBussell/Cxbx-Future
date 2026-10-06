@echo off
setlocal
cd /d "%~dp0"

rem Match the 14.33 toolchain identified in the September 2022 release.
set "CXBX_VS_COMPONENT=Microsoft.VisualStudio.Component.VC.14.33.17.3.x86.x64"
set "CXBX_TOOLSET_VERSION=14.33.31629"
set "CXBX_WINDOWS_SDK=10.0.19041.0"
set "CXBX_VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%CXBX_VSWHERE%" (
    echo Visual Studio Installer was not found.
    exit /b 1
)
set "CXBX_VS_INSTALL="
for /f "usebackq delims=" %%I in (`"%CXBX_VSWHERE%" -latest -products * -requires %CXBX_VS_COMPONENT% -property installationPath`) do set "CXBX_VS_INSTALL=%%I"
if not defined CXBX_VS_INSTALL (
    echo Install MSVC v143 VS 2022 C++ x64/x86 build tools v14.33-17.3 using Visual Studio Installer.
    echo Required component: %CXBX_VS_COMPONENT%
    exit /b 1
)
call "%CXBX_VS_INSTALL%\VC\Auxiliary\Build\vcvars32.bat" %CXBX_WINDOWS_SDK% -vcvars_ver=%CXBX_TOOLSET_VERSION%
if errorlevel 1 exit /b %errorlevel%

rem Use a fresh directory: modern-toolchain CMake caches cannot be reused.
if not defined CXBX_BUILD_DIRECTORY set "CXBX_BUILD_DIRECTORY=build-2022-v143"
for %%I in ("%CXBX_BUILD_DIRECTORY%") do set "CXBX_RELEASE_OUTPUT=%%~fI\bin\Release"
rem Keep binaries beside the shaders and DLLs copied by misc-batch.
cmake -S . -B "%CXBX_BUILD_DIRECTORY%" -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER="%VCToolsInstallDir:\=/%bin/Hostx86/x86/cl.exe" -DCMAKE_CXX_COMPILER="%VCToolsInstallDir:\=/%bin/Hostx86/x86/cl.exe" -DCMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE="%CXBX_RELEASE_OUTPUT%"
if errorlevel 1 exit /b %errorlevel%
cmake --build "%CXBX_BUILD_DIRECTORY%" --target cxbx %*
exit /b %errorlevel%

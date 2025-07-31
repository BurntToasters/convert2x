@echo off
setlocal enabledelayedexpansion
set "version=v1.0.1"

:start_loop
cls
echo CONVERT2: H.264 to AV1 Video Converter Script.
echo NOTE: This script uses the NVIDIA NVENC encoder for AV1 encoding.
echo Created by: BurntToasters.
echo Source: https://github.com/BurntToasters/convert2x
echo !version!
echo ===========================
echo.
echo This script converts videos from H.264 to AV1 using NVIDIA GPU acceleration.
echo All metadata will be removed from the output file.
echo.

:input
set /p "inputPath=Paste the full path to your video file (with quotes): "

:: Remove quotes from input path
set inputPath=!inputPath:"=!

:: file exists
if not exist "!inputPath!" (
    echo.
    echo Error: File not found. Please check the path and try again.
    echo.
    goto input
)

:: Get directory, filename, and extension
for %%i in ("!inputPath!") do (
    set "inputDir=%%~dpi"
    set "inputName=%%~ni"
    set "inputExt=%%~xi"
)

::conversion options
echo.
echo Conversion Options:
echo -----------------
echo Press ENTER for default settings (original resolution, 5M bitrate)
echo 1 = Downscale to 1080p with optimized bitrate (3M)
echo 2 = Downscale to 1080p optimized for streaming (2M bitrate)
echo.

set /p conversionOption="Enter your choice: "

:: conversion parameters
if "!conversionOption!"=="1" (
    set "outputSuffix=_av1_1080p.mp4"
    set "scaleOption=-vf scale=-1:1080"
    set "bitrateOption=-b:v 3M"
    echo.
    echo Selected: 1080p conversion with optimized bitrate
) else if "!conversionOption!"=="2" (
    set "outputSuffix=_1080p_av1_stream.mp4"
    set "scaleOption=-vf scale=-1:1080"
    set "bitrateOption=-b:v 2M -maxrate 2.5M -bufsize 4M"
    echo.
    echo Selected: 1080p conversion optimized for streaming
) else (
    set "outputSuffix=_av1.mp4"
    set "scaleOption="
    set "bitrateOption=-b:v 5M"
    echo.
    echo Selected: Default settings (original resolution)
)

:: spaces filename
echo.
echo Remove spaces from output filename? (y/n)
set /p removeSpaces="[n]: "

:: Process filename
if /i "!removeSpaces!"=="y" (
    :: Remove spaces
    set "processedName=!inputName: =_!"
    echo Spaces will be replaced with underscores in the filename.
) else (
    set "processedName=!inputName!"
    echo Original filename structure will be preserved.
)

:: final output
set "outputPath=!inputDir!!processedName!!outputSuffix!"

echo.
echo Input file:  "!inputPath!"
echo Output file: "!outputPath!"
echo.
echo Starting conversion...
echo.

:: ffmpeg command
if "!conversionOption!"=="2" (
    :: Streaming-optimized
    ffmpeg -threads 16 -i "!inputPath!" -map_metadata -1 !scaleOption! -c:v av1_nvenc -preset p6 -rc:v vbr -cq:v 30 !bitrateOption! -pix_fmt yuv420p -movflags faststart -c:a aac -b:a 128k "!outputPath!"
) else (
    :: Regular
    ffmpeg -threads 16 -i "!inputPath!" -map_metadata -1 !scaleOption! -c:v av1_nvenc -preset p5 -rc:v vbr -cq:v 28 !bitrateOption! -pix_fmt yuv420p -c:a copy "!outputPath!"
)

echo.
if %errorlevel% EQU 0 (
    echo Conversion completed successfully.
    echo All metadata has been removed from the output file.
) else (
    echo Error during conversion. Please check ffmpeg output for details.
)

echo.
echo.
echo Press ENTER to convert another file or type 'q' to quit:
set /p continueChoice=""

if /i "!continueChoice!"=="q" (
    echo.
    echo Exiting program. Thank you for using AV1 Video Converter.
    exit /b
) else (
    goto start_loop
)
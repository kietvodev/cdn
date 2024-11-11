@echo off
setlocal enabledelayedexpansion

:: Đường dẫn RTSP
set RTSP_URL=rtsp://admin:UHEGHG@server.iof.vn:5546/ch1/main

:: Đường dẫn gốc nơi bạn lưu video
set BASE_DIR=D:\CAMERA\SG_TRUOC_NHA

:: Định dạng file video đầu ra
set OUTPUT_FORMAT=mp4

:: Lấy thời gian hiện tại và lưu ngày trước đó
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set day=%datetime:~6,2%
set month=%datetime:~4,2%
set year=%datetime:~0,4%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set previous_date=%day%%month%%year%

:: Tạo thư mục ngày hiện tại
set date_folder=%previous_date%
set FOLDER=%BASE_DIR%\%date_folder%
if not exist "%FOLDER%" mkdir "%FOLDER%"

:: Định dạng tên file đầu ra
set OUTPUT_FILE=%FOLDER%\output.mp4

:: Hiển thị thông tin khởi tạo
echo ======================================================
echo [INFO] Bắt đầu ghi video.
echo [INFO] Ngày giờ hiện tại: %day%/%month%/%year% %hour%:%minute%
echo [INFO] Thư mục hiện tại: %FOLDER%
echo [INFO] File đầu ra: %OUTPUT_FILE%
echo ======================================================

:: Vòng lặp liên tục ghi video và chuyển sang thư mục mới khi ngày thay đổi
:loop
    :: Cập nhật thời gian hiện tại
    for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
    set day=%datetime:~6,2%
    set month=%datetime:~4,2%
    set year=%datetime:~0,4%
    set hour=%datetime:~8,2%
    set minute=%datetime:~10,2%
    set current_date=%day%%month%%year%

    :: Kiểm tra nếu ngày mới phát hiện
    if not "%current_date%"=="%previous_date%" (
        echo [INFO] Ngày mới phát hiện. Tạo thư mục mới...
        
        :: Cập nhật ngày và thư mục
        set previous_date=%current_date%
        set date_folder=%current_date%
        set FOLDER=%BASE_DIR%\%date_folder%
        if not exist "%FOLDER%" mkdir "%FOLDER%"
        set OUTPUT_FILE=%FOLDER%\output.mp4
        echo [INFO] Tạo thư mục mới: %FOLDER%
    )

    :: Ghi video vào file hiện tại, giới hạn thời gian ghi là 1 phút
    echo [INFO] Đang ghi video vào: %OUTPUT_FILE%
    ffmpeg -i "%RTSP_URL%" -c:v libx264 -preset fast -crf 23 -f mp4 "%OUTPUT_FILE%" -t 60

    :: Chờ trước khi kiểm tra lại
    timeout /t 1 >nul
goto loop

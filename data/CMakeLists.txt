# 카드 DB(sqlite)·덱 파일·스크립트 파일 읽기. 러너와 프레임이 같이 쓴다(코어는 파일을 직접 열지 않는다)
find_package(unofficial-sqlite3 CONFIG REQUIRED)
find_package(unofficial-lua-cpp CONFIG REQUIRED)

add_library(wxdata STATIC card_db.cpp deck_check.cpp)
target_include_directories(wxdata PUBLIC .)
# 코어 라이브러리는 링크하지 않는다(프레임은 코어를 DLL로 불러온다). 덱 검사용 Lua만
target_link_libraries(wxdata PUBLIC wxcore_headers unofficial::sqlite3::sqlite3 lua-cpp)
# 카드 DB·스크립트·덱 파일(레포 루트 기준)
target_compile_definitions(wxdata PRIVATE WX_DATA_DIR="${CMAKE_SOURCE_DIR}")

# 카드 DB(sqlite)·덱 파일·스크립트 파일 읽기. 러너와 프레임이 같이 쓴다(코어는 파일을 직접 열지 않는다)
find_package(unofficial-sqlite3 CONFIG REQUIRED)

add_library(wxdata STATIC card_db.cpp)
target_include_directories(wxdata PUBLIC .)
target_link_libraries(wxdata PUBLIC wxcore unofficial::sqlite3::sqlite3)
# 카드 DB·스크립트·덱 파일(레포 루트 기준)
target_compile_definitions(wxdata PRIVATE WX_DATA_DIR="${CMAKE_SOURCE_DIR}")

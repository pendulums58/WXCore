file(GLOB WX_CASES CONFIGURE_DEPENDS cases/*.cpp)

# 프레임의 대전 래퍼도 화면 없이 검증한다(SDL·ImGui에 의존하지 않는 파일)
add_executable(wx_runner main.cpp lua_cases.cpp fuzz.cpp ${CMAKE_SOURCE_DIR}/frame/game.cpp ${CMAKE_SOURCE_DIR}/frame/field_model.cpp ${CMAKE_SOURCE_DIR}/frame/net.cpp ${CMAKE_SOURCE_DIR}/frame/online.cpp ${WX_CASES})
target_include_directories(wx_runner PRIVATE . ${CMAKE_SOURCE_DIR}/frame)
find_package(Libevent CONFIG REQUIRED)
target_link_libraries(wx_runner PRIVATE wxcore wxdata libevent::core)
# Lua 케이스는 소스 폴더에서 바로 읽는다(다시 빌드하지 않고 추가·수정)
target_compile_definitions(wx_runner PRIVATE WX_CASES_DIR="${CMAKE_CURRENT_SOURCE_DIR}/cases")

file(GLOB WX_CASES CONFIGURE_DEPENDS cases/*.cpp)
add_executable(wx_runner main.cpp ${WX_CASES})
target_include_directories(wx_runner PRIVATE .)
target_link_libraries(wx_runner PRIVATE wxcore)

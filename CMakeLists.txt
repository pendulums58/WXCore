cmake_minimum_required(VERSION 3.25)
# 클라이언트 버전(자동 업데이트가 비교한다). 릴리즈마다 올린다
project(wxcore VERSION 0.2.0 LANGUAGES C CXX)

# 프레임(SDL3 + Dear ImGui). 코어와 러너는 프레임 없이 빌드된다
option(WX_BUILD_FRAME "SDL3 + Dear ImGui 프레임" ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
  # 소스에 한국어 주석이 있으므로 UTF-8 고정
  add_compile_options(/utf-8 /W4 /permissive-)
endif()

add_subdirectory(core)
add_subdirectory(data)
add_subdirectory(runner)
if(WX_BUILD_FRAME)
  add_subdirectory(frame)
endif()

enable_testing()
add_test(NAME runner COMMAND wx_runner)

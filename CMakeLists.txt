cmake_minimum_required(VERSION 3.25)
project(wxcore LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
  # 소스에 한국어 주석이 있으므로 UTF-8 고정
  add_compile_options(/utf-8 /W4 /permissive-)
endif()

add_subdirectory(core)
add_subdirectory(runner)

enable_testing()
add_test(NAME runner COMMAND wx_runner)

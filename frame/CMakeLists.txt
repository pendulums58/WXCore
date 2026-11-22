find_package(SDL3 CONFIG REQUIRED)
find_package(imgui CONFIG REQUIRED)
find_package(Stb REQUIRED)

add_executable(wx_frame main.cpp game.cpp view.cpp field.cpp textures.cpp)
target_include_directories(wx_frame PRIVATE ${Stb_INCLUDE_DIR})
target_link_libraries(wx_frame PRIVATE wxcore wxdata SDL3::SDL3 imgui::imgui)

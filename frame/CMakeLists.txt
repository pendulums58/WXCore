find_package(SDL3 CONFIG REQUIRED)
find_package(imgui CONFIG REQUIRED)
find_package(Stb REQUIRED)
find_package(Libevent CONFIG REQUIRED)

add_executable(wx_frame main.cpp game.cpp field_model.cpp net.cpp online.cpp view.cpp field.cpp deck_editor.cpp lobby.cpp textures.cpp)
target_include_directories(wx_frame PRIVATE ${Stb_INCLUDE_DIR})
target_link_libraries(wx_frame PRIVATE wxcore wxdata SDL3::SDL3 imgui::imgui libevent::core)

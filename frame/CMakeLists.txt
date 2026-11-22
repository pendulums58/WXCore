find_package(SDL3 CONFIG REQUIRED)
find_package(imgui CONFIG REQUIRED)
find_package(Stb REQUIRED)
find_package(Libevent CONFIG REQUIRED)

add_executable(wx_frame main.cpp core_loader.cpp game.cpp field_model.cpp net.cpp online.cpp view.cpp field.cpp deck_editor.cpp lobby.cpp textures.cpp)
target_include_directories(wx_frame PRIVATE ${Stb_INCLUDE_DIR})
target_link_libraries(wx_frame PRIVATE wxdata SDL3::SDL3 imgui::imgui libevent::core)
# 코어는 DLL로 불러온다(core_loader.cpp). 동봉 코어를 exe 옆에 둔다
add_dependencies(wx_frame wxcore_dll)
add_custom_command(TARGET wx_frame POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:wxcore_dll> $<TARGET_FILE_DIR:wx_frame>)

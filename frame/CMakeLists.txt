find_package(SDL3 CONFIG REQUIRED)
find_package(imgui CONFIG REQUIRED)
find_package(Stb REQUIRED)
find_package(Libevent CONFIG REQUIRED)
find_package(libgit2 CONFIG REQUIRED)
find_package(CURL REQUIRED)
find_package(miniz CONFIG REQUIRED)

add_executable(wx_frame main.cpp core_loader.cpp game.cpp field_model.cpp net.cpp online.cpp repo_manager.cpp updater.cpp view.cpp field.cpp deck_editor.cpp lobby.cpp textures.cpp)
target_include_directories(wx_frame PRIVATE ${Stb_INCLUDE_DIR})
target_link_libraries(wx_frame PRIVATE wxdata SDL3::SDL3 imgui::imgui libevent::core libgit2::libgit2package CURL::libcurl miniz::miniz)
# 클라이언트 버전(자동 업데이트가 update.json의 version과 비교한다)
target_compile_definitions(wx_frame PRIVATE WX_CLIENT_VERSION="${PROJECT_VERSION}")
# 코어는 DLL로 불러온다(core_loader.cpp). 동봉 코어를 exe 옆에 둔다
add_dependencies(wx_frame wxcore_dll)
add_custom_command(TARGET wx_frame POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:wxcore_dll> $<TARGET_FILE_DIR:wx_frame>)

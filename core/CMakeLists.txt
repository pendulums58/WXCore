find_package(unofficial-lua-cpp CONFIG REQUIRED)

set(WX_CORE_SOURCES
  src/rng.cpp
  src/zone.cpp
  src/card.cpp
  src/state.cpp
  src/effect.cpp
  src/duel.cpp
  src/calc.cpp
  src/script.cpp
  src/request.cpp
  src/cost.cpp
  src/trigger.cpp
  src/engine.cpp
  src/rules.cpp
  src/message.cpp
  src/session.cpp
  src/api.cpp
)

# 헤더만(카드 데이터 구조·공개 C API). 데이터 쪽(wxdata)은 코어를 링크하지 않고 이것만 쓴다
add_library(wxcore_headers INTERFACE)
target_include_directories(wxcore_headers INTERFACE include src)

# 정적 코어: 러너가 C++ API를 직접 링크한다(설계: 실행 위치)
add_library(wxcore STATIC ${WX_CORE_SOURCES})
target_link_libraries(wxcore PUBLIC wxcore_headers lua-cpp)

# 코어 DLL: 프레임이 불러 쓴다. 저장소(repositories/*/bin)로 받은 코어로 바꿔 낄 수 있다(EDOPro의 ocgcore와 같음)
add_library(wxcore_dll SHARED ${WX_CORE_SOURCES})
set_target_properties(wxcore_dll PROPERTIES OUTPUT_NAME wxcore ARCHIVE_OUTPUT_NAME wxcore_dll)  # 가져오기 lib가 정적 wxcore.lib를 덮지 않게
target_compile_definitions(wxcore_dll PRIVATE WX_BUILD_DLL)
target_link_libraries(wxcore_dll PRIVATE wxcore_headers lua-cpp)

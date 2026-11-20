find_package(unofficial-lua-cpp CONFIG REQUIRED)

add_library(wxcore STATIC
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
target_include_directories(wxcore
  PUBLIC include
  PUBLIC src  # 러너는 C++ API를 직접 링크한다(설계: 실행 위치)
)
target_link_libraries(wxcore PUBLIC lua-cpp)

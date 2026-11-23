#pragma once
// 코어 DLL 불러오기(EDOPro의 ocgcore 동적 로딩과 같음).
// 저장소로 받은 코어(configs.json에서 has_core인 저장소의 bin/wxcore.dll)가 API major·스키마가 맞으면 그것을,
// 아니면 exe 옆의 동봉 코어를 쓴다.
// 이 파일이 wx_api.h의 함수들을 정의하고, 불러온 DLL의 같은 함수로 넘긴다.
#include <string>

namespace wxframe {

struct CoreInfo {
  std::string path;        // 불러온 DLL
  bool from_repo = false;  // 저장소 코어인가(아니면 동봉)
  unsigned major = 0, minor = 0;
  std::string skipped;     // 버전이 안 맞아 건너뛴 저장소 코어(있으면 「클라이언트 업데이트 필요」)
};

bool load_core(CoreInfo& info, std::string& err);
const CoreInfo& core_info();

}  // namespace wxframe

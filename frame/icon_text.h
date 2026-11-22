#pragma once
// 카드 텍스트의 아이콘 토큰(《コインアイコン》·【出】 등)을 그림으로 바꾸는 매핑.
// 데이터 폴더마다 icons/icons.json({"토큰": "그림 파일"}, 그림은 같은 icons/ 폴더). data_dirs 순서로 읽고 뒤가 덮는다.
// 그림 파일이 없는 토큰은 매핑하지 않는다(원문 그대로). 화면 없이 테스트할 수 있게 ImGui를 쓰지 않는다.
#include <map>
#include <string>
#include <vector>

namespace wxframe {

class IconMap {
 public:
  struct Segment {
    std::string text;   // 글자(image가 비었을 때)
    std::string image;  // 그림 파일 전체 경로(아이콘일 때)
  };

  // 데이터 폴더들(우선순위 낮은 것부터)의 icons/icons.json을 읽는다. 읽은 파일 수
  int load(const std::vector<std::string>& dirs);
  // JSON 내용 하나를 더한다(그림 경로는 icons_dir 기준). 형식이 틀리면 false
  bool add(const std::string& json, const std::string& icons_dir, bool check_files = true);
  void clear();
  size_t size() const { return map_.size(); }

  // 글자와 아이콘으로 나눈다. 같은 자리에서 여러 토큰이 맞으면 가장 긴 것
  std::vector<Segment> split(const std::string& text) const;

 private:
  std::map<std::string, std::string> map_;  // 토큰 → 그림 경로
};

}  // namespace wxframe

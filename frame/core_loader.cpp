#include "core_loader.h"

#include <filesystem>
#include <vector>

#include "card_db.h"
#include "repo_manager.h"
#include "wx_api.h"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <dlfcn.h>
#endif

namespace wxframe {

namespace {

namespace fs = std::filesystem;

#ifdef _WIN32
using Lib = HMODULE;
Lib open_lib(const std::string& path) { return LoadLibraryW(fs::path(path).wstring().c_str()); }
void* symbol(Lib l, const char* name) { return reinterpret_cast<void*>(GetProcAddress(l, name)); }
void close_lib(Lib l) { FreeLibrary(l); }
std::string exe_dir() {
  wchar_t buf[MAX_PATH];
  GetModuleFileNameW(nullptr, buf, MAX_PATH);
  return fs::path(buf).parent_path().string();
}
const char* kDll = "wxcore.dll";
#else
using Lib = void*;
Lib open_lib(const std::string& path) { return dlopen(path.c_str(), RTLD_NOW | RTLD_LOCAL); }
void* symbol(Lib l, const char* name) { return dlsym(l, name); }
void close_lib(Lib l) { dlclose(l); }
std::string exe_dir() { return fs::read_symlink("/proc/self/exe").parent_path().string(); }
const char* kDll = "libwxcore.so";
#endif

// 함수 목록(wx_api.h의 WX_API 함수 전부)
#define WX_CORE_FUNCS(X)                                                                                           \
  X(wx_api_version) X(wx_schema_version) X(wx_create_duel) X(wx_destroy_duel) X(wx_add_deck) X(wx_add_deck_prints) X(wx_start)           \
  X(wx_process) X(wx_get_messages) X(wx_set_response) X(wx_cancel) X(wx_query_card) X(wx_query_granted) X(wx_query_zone)               \
  X(wx_query_under) X(wx_query_attached) X(wx_query_player) X(wx_query_game) X(wx_zone_count) X(wx_query_zone_info) X(wx_dump_message) \
  X(wx_test_add_card) X(wx_test_begin) X(wx_test_move_card) X(wx_test_set_power) X(wx_test_undo)

struct Table {
#define DECL(f) decltype(&::f) f = nullptr;
  WX_CORE_FUNCS(DECL)
#undef DECL
};

Table g_t;
Lib g_lib = nullptr;
CoreInfo g_info;

// 함수를 모두 찾고 버전이 맞으면 true(표를 채운다)
bool try_load(const std::string& path, Table& t, Lib& lib, unsigned& major, unsigned& minor, std::string& why) {
  lib = open_lib(path);
  if (!lib) {
    why = "파일을 열지 못함(없거나 필요한 DLL이 없음)";
    return false;
  }
  bool all = true;
#define LOAD(f)                                               \
  t.f = reinterpret_cast<decltype(t.f)>(symbol(lib, #f)); \
  all &= t.f != nullptr;
  WX_CORE_FUNCS(LOAD)
#undef LOAD
  if (!all) why = "이 프레임이 쓰는 함수가 없음(옛 코어)";
  if (all) {
    const uint32_t v = t.wx_api_version();
    major = v >> 16;
    minor = v & 0xFFFF;
    // major가 같고, 이 프레임이 아는 minor 이상이며, 스키마가 같아야 한다
    all = major == WX_API_VERSION_MAJOR && minor >= WX_API_VERSION_MINOR && t.wx_schema_version() == WX_SCHEMA_VERSION;
    if (!all)
      why = "버전이 안 맞음(API " + std::to_string(major) + "." + std::to_string(minor) + ", 스키마 " +
            std::to_string(t.wx_schema_version()) + ")";
  }
  if (!all) {
    close_lib(lib);
    lib = nullptr;
  }
  return all;
}

}  // namespace

bool load_core(CoreInfo& info, std::string& err) {
  info = CoreInfo{};
  // 저장소 코어: configs.json에서 has_core인 저장소의 bin/wxcore.dll만(적힌 순서로 앞이 우선).
  // 오리카 팩 같은 다른 저장소에 DLL이 섞여 있어도 코어로 실행하지 않는다(지시 2026-11-23 #2).
  // 배포판(exe 옆에 config/)으로 실행할 때만 쓴다. 개발 중에는 방금 빌드한 동봉 코어가 늘 이겨야 한다
  std::vector<std::string> repo;
  std::error_code ec;
  if (fs::is_directory(fs::path(exe_dir()) / "config", ec)) {
    std::vector<RepoConfig> repos;
    std::string update_url, cfg_err;  // 설정을 못 읽으면 저장소 코어 없이 동봉 코어
    if (load_repo_config(wxtest::data_dir() + "/config/configs.json", repos, update_url, cfg_err))
      repo = repo_core_paths(repos, kDll);
  }
  std::vector<std::pair<std::string, bool>> order;
  for (const auto& r : repo) order.emplace_back(r, true);
  order.emplace_back((fs::path(exe_dir()) / kDll).string(), false);
  for (const auto& [path, from_repo] : order) {
    Table t;
    Lib lib = nullptr;
    unsigned major = 0, minor = 0;
    std::string why;
    if (try_load(path, t, lib, major, minor, why)) {
      g_t = t;
      g_lib = lib;
      info.path = path;
      info.from_repo = from_repo;
      info.major = major;
      info.minor = minor;
      g_info = info;
      return true;
    }
    if (from_repo && info.skipped.empty()) info.skipped = path + ": " + why;
    err = std::string("코어(") + kDll + ")를 불러오지 못했다: " + why + ". exe 옆에 있어야 한다";
  }
  g_info = info;
  return false;
}

const CoreInfo& core_info() { return g_info; }

}  // namespace wxframe

// ── wx_api.h 함수: 불러온 코어로 넘긴다 ──
using wxframe::g_t;

extern "C" {

uint32_t wx_api_version(void) { return g_t.wx_api_version(); }
uint32_t wx_schema_version(void) { return g_t.wx_schema_version(); }
int wx_create_duel(const wx_duel_options* opt, wx_duel** out) { return g_t.wx_create_duel(opt, out); }
void wx_destroy_duel(wx_duel* duel) { g_t.wx_destroy_duel(duel); }
int wx_add_deck(wx_duel* duel, uint8_t player, const uint32_t* main, size_t n_main, const uint32_t* lrig, size_t n_lrig) {
  return g_t.wx_add_deck(duel, player, main, n_main, lrig, n_lrig);
}
int wx_add_deck_prints(wx_duel* duel, uint8_t player, const uint32_t* main, const uint16_t* main_prints, size_t n_main,
                       const uint32_t* lrig, const uint16_t* lrig_prints, size_t n_lrig) {
  return g_t.wx_add_deck_prints(duel, player, main, main_prints, n_main, lrig, lrig_prints, n_lrig);
}
int wx_start(wx_duel* duel) { return g_t.wx_start(duel); }
int wx_process(wx_duel* duel) { return g_t.wx_process(duel); }
size_t wx_get_messages(wx_duel* duel, uint8_t view, uint8_t* buf, size_t cap) { return g_t.wx_get_messages(duel, view, buf, cap); }
int wx_set_response(wx_duel* duel, const uint32_t* picks, size_t n) { return g_t.wx_set_response(duel, picks, n); }
int wx_cancel(wx_duel* duel) { return g_t.wx_cancel(duel); }
int wx_query_card(wx_duel* duel, uint8_t view, uint32_t handle, wx_card_info* out) {
  return g_t.wx_query_card(duel, view, handle, out);
}
size_t wx_query_zone(wx_duel* duel, uint8_t view, uint16_t zone, uint32_t* buf, size_t cap) {
  return g_t.wx_query_zone(duel, view, zone, buf, cap);
}
size_t wx_query_under(wx_duel* duel, uint8_t view, uint32_t handle, uint32_t* buf, size_t cap) {
  return g_t.wx_query_under(duel, view, handle, buf, cap);
}
size_t wx_query_attached(wx_duel* duel, uint8_t view, uint32_t handle, uint32_t* buf, size_t cap) {
  return g_t.wx_query_attached(duel, view, handle, buf, cap);
}
size_t wx_query_granted(wx_duel* duel, uint8_t view, uint32_t handle, wx_granted_info* buf, size_t cap) {
  return g_t.wx_query_granted(duel, view, handle, buf, cap);
}
int wx_query_player(wx_duel* duel, uint8_t player, wx_player_info* out) { return g_t.wx_query_player(duel, player, out); }
int wx_query_game(wx_duel* duel, wx_game_info* out) { return g_t.wx_query_game(duel, out); }
size_t wx_zone_count(wx_duel* duel) { return g_t.wx_zone_count(duel); }
int wx_query_zone_info(wx_duel* duel, uint16_t zone, char* name, size_t cap, uint8_t* owner, uint8_t* gate) {
  return g_t.wx_query_zone_info(duel, zone, name, cap, owner, gate);
}
size_t wx_dump_message(const uint8_t* msg, size_t len, char* out, size_t cap) { return g_t.wx_dump_message(msg, len, out, cap); }
int wx_test_add_card(wx_duel* duel, uint32_t cid, uint8_t owner, uint16_t zone, uint32_t* handle) {
  return g_t.wx_test_add_card(duel, cid, owner, zone, handle);
}
int wx_test_begin(wx_duel* duel, uint8_t turn_player, uint32_t phase, int first_turn) {
  return g_t.wx_test_begin(duel, turn_player, phase, first_turn);
}
int wx_test_move_card(wx_duel* duel, uint32_t handle, uint16_t zone, int bottom, uint32_t* new_handle) {
  return g_t.wx_test_move_card(duel, handle, zone, bottom, new_handle);
}
int wx_test_set_power(wx_duel* duel, uint32_t handle, int32_t power) { return g_t.wx_test_set_power(duel, handle, power); }
int wx_test_undo(wx_duel* duel) { return g_t.wx_test_undo(duel); }

}  // extern "C"

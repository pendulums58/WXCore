// 최소 프레임: SDL3 창 + Dear ImGui(SDL 렌더러). 핫시트로 두 사람이 번갈아 한다.
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <imgui.h>
#include <imgui_impl_sdl3.h>
#include <imgui_impl_sdlrenderer3.h>

#include <cstdio>
#include <filesystem>
#include <sstream>
#include <string>
#include <vector>

#include "card_db.h"
#include "core_loader.h"
#include "view.h"

namespace {

// 카드 텍스트가 일본어·한국어라 두 글꼴을 합친다(Windows 기본 글꼴)
void load_fonts(ImGuiIO& io, float size) {
  const char* jp[] = {"C:/Windows/Fonts/meiryo.ttc", "C:/Windows/Fonts/YuGothM.ttc", "C:/Windows/Fonts/msgothic.ttc"};
  const char* ko[] = {"C:/Windows/Fonts/malgun.ttf", "C:/Windows/Fonts/gulim.ttc"};
  ImFont* base = nullptr;
  for (const char* f : ko)
    if (std::filesystem::exists(f)) {
      base = io.Fonts->AddFontFromFileTTF(f, size, nullptr, io.Fonts->GetGlyphRangesKorean());
      break;
    }
  if (!base) {
    io.Fonts->AddFontDefault();
    return;
  }
  ImFontConfig merge;
  merge.MergeMode = true;
  // 카드 텍스트에 나오는 기호(①②·※·…·→·■△★ 등). 일본어 범위에 없어 따로 합친다. 글꼴을 다 만들 때까지 살아 있어야 한다
  static const ImWchar symbols[] = {0x2010, 0x205F, 0x2190, 0x21FF, 0x2460, 0x24FF, 0x25A0, 0x25FF, 0x2600, 0x26FF, 0};
  for (const char* f : jp)
    if (std::filesystem::exists(f)) {
      io.Fonts->AddFontFromFileTTF(f, size, &merge, io.Fonts->GetGlyphRangesJapanese());
      io.Fonts->AddFontFromFileTTF(f, size, &merge, symbols);
      break;
    }
}

}  // namespace

int main(int argc, char** argv) {
  if (!SDL_Init(SDL_INIT_VIDEO)) {
    std::fprintf(stderr, "SDL_Init: %s\n", SDL_GetError());
    return 1;
  }
  SDL_WindowFlags flags = SDL_WINDOW_RESIZABLE | SDL_WINDOW_HIGH_PIXEL_DENSITY;
  int win_w = 1600, win_h = 960;
  for (int i = 1; i < argc; ++i) {
    const std::string a = argv[i];
    if (a == "--shot") flags |= SDL_WINDOW_HIDDEN;  // 저장만 하므로 창을 띄우지 않는다
    if (a == "--size" && i + 1 < argc) std::sscanf(argv[i + 1], "%dx%d", &win_w, &win_h);  // 창 크기 확인용
  }
  SDL_Window* window = SDL_CreateWindow("WIXOSS 시뮬레이터", win_w, win_h, flags);
  SDL_Renderer* renderer = window ? SDL_CreateRenderer(window, nullptr) : nullptr;
  if (!renderer) {
    std::fprintf(stderr, "창/렌더러: %s\n", SDL_GetError());
    return 1;
  }
  SDL_SetRenderVSync(renderer, 1);
  SDL_SetWindowMinimumSize(window, 1024, 640);  // 이보다 작으면 장 글자가 겹친다

  // 코어 DLL: 저장소 코어가 버전이 맞으면 그것, 아니면 동봉 코어
  wxframe::CoreInfo core;
  std::string core_err;
  if (!wxframe::load_core(core, core_err)) {
    SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "WIXOSS 시뮬레이터", core_err.c_str(), window);
    return 1;
  }

  IMGUI_CHECKVERSION();
  ImGui::CreateContext();
  ImGuiIO& io = ImGui::GetIO();
  io.IniFilename = nullptr;
  const float scale = SDL_GetWindowDisplayScale(window);
  load_fonts(io, 17.0f * (scale > 0 ? scale : 1.0f));
  ImGui::StyleColorsDark();
  ImGui::GetStyle().ScaleAllSizes(scale > 0 ? scale : 1.0f);
  ImGui_ImplSDL3_InitForSDLRenderer(window, renderer);
  ImGui_ImplSDLRenderer3_Init(renderer);

  {  // 텍스처는 렌더러보다 먼저 지운다
    wxframe::Textures textures(renderer);
    wxframe::App app(textures);
    // --shot <파일.bmp>: 몇 프레임 그린 뒤 화면을 저장하고 끝낸다(화면 확인용)
    std::string shot;
    int shot_frames = 0;
    // --click "x,y;rx,y": 화면 좌표를 차례로 누른다(10프레임마다 하나, r을 붙이면 우클릭). 조작 확인용, --shot과 같이 쓴다
    std::vector<ImVec2> clicks;
    int shot_at = 0;  // --shot-at N: N프레임째에 저장(기본은 클릭이 끝나고 10프레임 뒤)
    std::vector<int> buttons;
    // 저장소 받기: 화면 확인용 실행(--shot)이나 --no-update면 건너뛴다. --update면 그래도 받는다(확인용)
    bool update = true, force = false;
    for (int i = 1; i < argc; ++i) {
      const std::string a = argv[i];
      if (a == "--shot" || a == "--no-update") update = false;
      if (a == "--update") force = true;
    }
    update |= force;
    if (update) {
      wxframe::Updater::remove_old_files(wxtest::data_dir());  // 지난 업데이트가 남긴 .old
      app.start_repos();
    }
    // --until-hint H: --auto가 그 힌트의 요청에 닿으면 멈춘다(화면 확인용)
    uint32_t until_hint = 0;
    for (int i = 1; i + 1 < argc; ++i)
      if (std::string(argv[i]) == "--until-hint") until_hint = static_cast<uint32_t>(std::stoul(argv[i + 1]));
    for (int i = 1; i < argc; ++i) {
      const std::string a = argv[i];
      if (a == "--decks" && i + 2 < argc) {  // --start보다 먼저 적는다
        app.pick_decks(argv[i + 1], argv[i + 2]);
        i += 2;
      }
      if (a == "--start") app.quick_start();
      if (a == "--shot" && i + 1 < argc) shot = argv[++i];
      if (a == "--auto" && i + 1 < argc) app.auto_play(std::stoi(argv[++i]), 1, until_hint);
      if (a == "--click" && i + 1 < argc) {
        std::stringstream ss(argv[++i]);
        std::string item;
        while (std::getline(ss, item, ';')) {
          float x = 0, y = 0;
          const bool right = !item.empty() && item[0] == 'r';
          if (std::sscanf(item.c_str() + (right ? 1 : 0), "%f,%f", &x, &y) == 2) {
            clicks.push_back(ImVec2(x, y));
            buttons.push_back(right ? 1 : 0);
          }
        }
      }
      if (a == "--host-local" && i + 1 < argc) app.dev_host(std::stoi(argv[++i]));
      if (a == "--join" && i + 2 < argc) {
        app.dev_join(argv[i + 1], std::stoi(argv[i + 2]));
        i += 2;
      }
      if (a == "--shot-at" && i + 1 < argc) shot_at = std::stoi(argv[++i]);
      if (a == "--preview" && i + 1 < argc) app.set_preview(static_cast<uint32_t>(std::stoul(argv[++i])));
    }
    bool done = false;
    while (!done) {
      SDL_Event e;
      while (SDL_PollEvent(&e)) {
        ImGui_ImplSDL3_ProcessEvent(&e);
        if (e.type == SDL_EVENT_QUIT) done = true;
        if (e.type == SDL_EVENT_WINDOW_CLOSE_REQUESTED && e.window.windowID == SDL_GetWindowID(window)) done = true;
      }
      if (app.quit_requested()) done = true;
      if (SDL_GetWindowFlags(window) & SDL_WINDOW_MINIMIZED) {
        SDL_Delay(10);
        continue;
      }
      ImGui_ImplSDLRenderer3_NewFrame();
      ImGui_ImplSDL3_NewFrame();
      if (!clicks.empty()) {
        // 0: 옮기기, 2: 누르기, 3: 떼기
        const int k = shot_frames / 10, t = shot_frames % 10;
        if (k < static_cast<int>(clicks.size())) {
          if (t == 0) io.AddMousePosEvent(clicks[k].x, clicks[k].y);
          if (t == 2) io.AddMouseButtonEvent(buttons[k], true);
          if (t == 3) io.AddMouseButtonEvent(buttons[k], false);
        }
      }
      ImGui::NewFrame();
      app.draw();
      ImGui::Render();
      SDL_SetRenderScale(renderer, io.DisplayFramebufferScale.x, io.DisplayFramebufferScale.y);
      SDL_SetRenderDrawColor(renderer, 24, 26, 32, 255);
      SDL_RenderClear(renderer);
      ImGui_ImplSDLRenderer3_RenderDrawData(ImGui::GetDrawData(), renderer);
      ++shot_frames;
      if (!shot.empty() && shot_frames == (shot_at > 0 ? shot_at : 10 * (static_cast<int>(clicks.size()) + 1))) {
        if (SDL_Surface* s = SDL_RenderReadPixels(renderer, nullptr)) {
          SDL_SaveBMP(s, shot.c_str());
          SDL_DestroySurface(s);
        }
        done = true;
      }
      SDL_RenderPresent(renderer);
    }
  }

  ImGui_ImplSDLRenderer3_Shutdown();
  ImGui_ImplSDL3_Shutdown();
  ImGui::DestroyContext();
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();
  return 0;
}

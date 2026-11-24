-- 스크립트 환경: 오리카 팩의 스크립트가 파일·프로세스에 손대지 못한다(점검 2026-11-24 #3-3)

case("샌드박스: os·io·debug·package·load가 없다", "점검 2026-11-24 #3-3", function(t)
  t:signi(300, 1000)
  t:script(300, [[
local s,id=GetID()
function s.initial_effect(c)
  seen={}
  for _,n in ipairs{"os","io","debug","package","require","load","loadfile","dofile","coroutine","collectgarbage"} do
    if _G[n]~=nil then seen[#seen+1]=n end
  end
  if string.dump then seen[#seen+1]="string.dump" end
  ok=math.max(1,2)==2 and ("a"):upper()=="A" and #table.pack(1,2)==2 and utf8.char(0x41)=="A" and math.random(3)<=3
end]])
  t:start()
  t:put(300, 0, "hand")
  t:expect(t:global("seen") == "", t:global("seen"))
  t:expect(t:global("ok") == true or t:global("ok") == "true")
end)

case("샌드박스: 바이트코드 스크립트는 읽지 않는다", "점검 2026-11-24 #3-3", function(t)
  t:allow_logs()
  t:signi(301, 1000)
  t:script(301, string.char(27) .. "Lua" .. string.rep(string.char(0), 40))
  t:start()
  t:put(301, 0, "hand")
  t:expect(t:logs() > 0)
end)

-- WX05-016 エンドホール
-- このアーツの使用コストで《白》《赤》《青》《緑》《黒》すべてが支払われている場合、このターンを終了する。（効果やルールによってターンが終了した時点で、チェックゾーンのカードはトラッシュに置かれ、ターンプレイヤーは手札を６枚になるように捨てて、「このターン」「ターン終了時まで」といった効果は終了する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 낸 에나로 5색이 각각 지불됐는가. 【マルチエナ】는 그중 한 색으로만(FAQ 1·3)
  e1:SetOperation(function(e,tp)
    local paid={}
    for x in Duel.GetPaidEna():Iter() do paid[#paid+1]=x end
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}
    local used={}
    local function try(i)
      if i>#cols then return true end
      for j,x in ipairs(paid) do
        if not used[j] and (x:IsColor(cols[i]) or x:HasKeyword(EFFECT_MULTI_ENA)) then
          used[j]=true
          if try(i+1) then return true end
          used[j]=nil
        end
      end
      return false
    end
    if try(1) then Duel.EndTurn() end
  end)
  c:RegisterEffect(e1)
end

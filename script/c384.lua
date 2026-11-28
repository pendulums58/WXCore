-- PR-K060 虚鍵の閻魔　ウリス（ウィクロスカード大全Ｋ-Ⅲ 付録）
-- このキーはあなたのエナゾーンにあるカードが持つ色が合計３種類以上ある場合にしか新たに場に出せない。
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード４：あなたの手札を１枚選ぶ。対戦相手は《白2》《赤2》《青2》《緑2》《黒2》《無2》から１つを宣言する。そのカードを公開し、それが宣言されたアイコンを持つカードではない場合、対戦相手のすべてのシグニをトラッシュに置く。
-- 【常】：あなたは限定条件を無視してアーツを使用できる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 에나의 색이 3종류 이상일 때만 새로 낸다
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e)
    local col,n=0,0
    for x in Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_ENA,0,nil):Iter() do col=col|x:GetColor() end
    for _,b in ipairs({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}) do if col&b~=0 then n=n+1 end end
    return n<3
  end)
  c:RegisterEffect(e1)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetDescription(aux.Ability(id,2))
  g:SetRange(LOCATION_LRIG)
  g:SetTiming(TIMING_ATTACK)
  g:SetExceedCost(4)
  g:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
    if not x then return end
    local m=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5))
    Duel.RevealCards(Group.CreateGroup(x))
    -- 그 아이콘(코스트의 같은 색 2개)을 가졌는가
    local sym=({"W","R","U","G","B","C"})[m+1]
    local _,n=x:GetEnaCost():gsub("{"..sym.."}","")
    if n<2 then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
  end)
  local e91=Effect.CreateEffect(c)
  e91:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 센터 루리그가 얻는다
  e91:SetDescription(aux.Ability(id,1))
  e91:SetCode(EFFECT_GRANT)
  e91:SetRange(LOCATION_KEY)
  e91:SetTargetRange(LOCATION_LRIG,0)
  e91:SetLabelObject(g)
  c:RegisterEffect(e91)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 아츠의 한정 조건 무시
  e2:SetDescription(aux.Ability(id,3))
  e2:SetCode(EFFECT_IGNORE_LIMIT)
  e2:SetRange(LOCATION_KEY)
  e2:SetTargetRange(1,0)
  c:RegisterEffect(e2)
end

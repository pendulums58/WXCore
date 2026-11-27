-- WX05-006 虚無の閻魔　ウリス
-- 【グロウ】あなたのエナゾーンにあるカードが持つ色が３種類以上
-- 【常】：あなたのエナゾーンにあるカードは【マルチエナ】を持つ。
-- 【常】：あなたが使用するアーツとスペルの限定条件は無視される。
-- 【起】エクシード５：あなたの手札を１枚選ぶ。対戦相手は《白2》《赤2》《青2》《緑2》《黒2》《無2》から１つを宣言する。そのカードを公開し、それが宣言されたアイコンを持つカードではない場合、対戦相手のすべてのシグニをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (function()
      local n=0
      -- 무색·【マルチエナ】는 색이 아니다(FAQ 2·3)
      for _,col in ipairs({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}) do
        if Duel.GetMatchingGroup(function(x) return x:IsColor(col) end,tp,LOCATION_ENA,0,nil):GetCount()>0 then n=n+1 end
      end
      return n>=3
    end)() end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_ENA,0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_IGNORE_LIMIT)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(1,0)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(5)
  -- 상대가 6가지 중 하나를 선언. 고른 카드가 그 색 아이콘이 아니면(FAQ 1·8)
  e3:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
    if not x then return end
    -- 오른쪽 위의 색 아이콘(코스트가 아니다. 색 변경도 따른다. FAQ 8·9)
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK,0}
    local k=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5))+1
    Duel.RevealCards(x)
    if (cols[k]==0 and x:GetColor()==0) or (cols[k]~=0 and x:IsColor(cols[k])) then return end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end

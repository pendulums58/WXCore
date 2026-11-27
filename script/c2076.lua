-- WX05-004 五型緑姫
-- 【グロウ】あなたのセンタールリグがカード名に《緑姫》を含む
-- 【常】：このルリグはあなたのルリグトラッシュにあるルリグの【起】能力を持つ。
-- 【出】：あなたのデッキの一番上のカードをライフクロスに加える。
-- 【起】エクシード５：各プレイヤーは自分のエナゾーンからすべての、白、赤、青、緑、黒のカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《緑姫》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"緑姫")
    end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】 루리그 트래시 루리그의 【起】를 가진다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_LTRASH_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(5)
  e3:SetOperation(function(e,tp)
    -- 무색은 남는다
    local g=Duel.GetMatchingGroup(function(x) return x:GetColor()~=0 end,tp,LOCATION_ENA,LOCATION_ENA,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end

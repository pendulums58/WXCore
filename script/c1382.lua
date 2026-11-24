-- WD23-025-E 幻水　ジュゴン
-- 【常】：あなたのセンタールリグが青で、このシグニが中央のシグニゾーンにあるかぎり、このシグニは「【自】：このシグニがアタックしたとき、カード名１つを宣言する。対戦相手はデッキの一番上を公開する。それが宣言されたカードである場合、あなたはカードを２枚引く。」を得る。
-- ライフバースト：カードを１枚引き、対戦相手のデッキの一番上と対戦相手のライフクロスの一番上を見る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if not tc then return end
    Duel.RevealCards(tc)
    if tc:IsCardName(cid) then Duel.Draw(tp,2) end
  end)
  -- [の間] 【常】 센터 루리그가 파랑이고 가운데 존에 있는 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x)
    if x~=e:GetHandler() or not x:IsInZone("signi_center") then return false end
    local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst()
    return lc~=nil and lc:IsColor(COLOR_BLUE)
  end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    for _,g in ipairs{Duel.GetDecktopGroup(1-tp,1),Duel.GetLifetopGroup(1-tp,1)} do
      if g:GetCount()>0 then Duel.ConfirmCards(tp,g) end
    end
  end)
  c:RegisterEffect(e2)
end

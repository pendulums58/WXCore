-- WXK09-037 紡槍　アークエナジェ
-- 【出】：対戦相手は色１つを宣言する。対戦相手のエナゾーンから宣言された色を持たず無色ではないすべてのカードをトラッシュに置く。
-- 【常】：対戦相手はこのシグニの【出】能力で宣言された色を持たず無色ではない、アーツとスペルを使用できない。
-- 【常】：対戦相手のエナゾーンにこのシグニの【出】能力で宣言された色を持たず無色ではないカードが置かれる場合、代わりにトラッシュに置かれる。
-- 【自】：各アタックフェイズ開始時、対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから無色のカードを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local s0={}
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}
    local col=cols[Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))+1]
    s0[e:GetHandler()]=col
    local g=Duel.GetMatchingGroup(function(x) return x:GetColor()~=0 and not x:IsColor(col) end,1-tp,LOCATION_ENA,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  -- 【常】 두 개(아츠·스펠 사용 금지, 에나에 놓일 때 트래시로)는 아직
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e4:SetRange(LOCATION_SZONE)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToTrash(tc,REASON_EFFECT)
    end
  end)
  c:RegisterEffect(e4)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:GetColor()==0 end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end

-- WX06-014 創造の鍵主　ウムル＝フェム
-- 【グロウ】あなたのセンタールリグがカード名に《ウムル》を含む
-- 【出】：数字１つを宣言する。あなたのデッキの上からカードを宣言した数字に等しい枚数トラッシュに置く。
-- 【起】《ターン１回》エクシード１：対戦相手のシグニ１体を対象とし、あなたのトラッシュから《古代兵器》のシグニ５枚を好きな順番でデッキの一番下に置く。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《ウムル》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"ウムル")
    end
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  -- 0도 선언할 수 있다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local n=Duel.AnnounceNumber(tp,0,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount())
    if n>0 then Duel.SendToTrash(Duel.GetDecktopGroup(tp,n),REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetExceedCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_TRASH,0,nil)
    -- 5장이 없으면 하나도 두지 않는다(FAQ 3)
    if g:GetCount()<5 then return end
    local pick=Duel.SelectCards(tp,g,5,5)
    Duel.SendToDeckBottom(Duel.SelectOrder(tp,pick),false)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end

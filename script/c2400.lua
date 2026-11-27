-- WX10-024 黒幻蟲　クマムス
-- 【出現条件】 《アタックフェイズアイコン》＜凶蟲＞のシグニ２枚をあなたのエナゾーンからトラッシュに置く
-- 【常】：このシグニがバニッシュされる場合、ルリグデッキに戻る代わりにルリグトラッシュに置かれる。
-- 【出】：対戦相手のシグニ１体を対象とし、対戦相手のデッキの一番上のカードをそれの【チャーム】にする。このターン、対戦相手が《無》《無》《無》を支払わないかぎりそれはアタックできない。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,LOCATION_ENA,TIMING_ATTACK)
  -- [の間] 【常】
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_SINGLE)
  e9:SetDescription(aux.Ability(id,1))
  e9:SetCode(EFFECT_RESONA_TO_LTRASH)
  e9:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e9)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if top and not tc:GetCharm() then Duel.Charm(top,tc) end
    -- 「このターン、《無》《無》《無》を支払わないかぎりアタックできない」(근사: 어택할 때 낼 수 없으면 무효)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_ATTACK)
    e1:SetCondition(function(e2,tp2,eg) return eg:GetFirst()==tc end)
    e1:SetOperation(function()
      local p=1-tp
      if Duel.CanPayEna(p,"{C}{C}{C}") and Duel.SelectYesNo(p) then
        Duel.SendToTrash(Duel.SelectEnaCost(p,"{C}{C}{C}"),REASON_COST)
      else
        Duel.NegateAttack()
      end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end

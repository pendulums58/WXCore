-- WD06-008 バツ・エニー・アザー
-- 数字１つを宣言する。あなたのライフクロスの一番上を公開する。そのカードがあなたの宣言した数字と同じレベルのシグニの場合、このターン、あなたのライフクロスはクラッシュされない。
-- このターン終了時、あなたのライフクロスの一番上のカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 라이프 클로스가 없으면 공개할 수 없어 거기서 끝(FAQ 5). 어느 턴이든 「このターン」 끝에 놓는다(FAQ 3)
function s.op(e,tp)
  local n=Duel.AnnounceNumber(tp,0,5)
  local tc=Duel.GetLifetopGroup(tp,1):GetFirst()
  if not tc then return end
  Duel.RevealCards(tc)
  if tc:IsSigni() and tc:GetLevel()==n then
    -- [まで] このターン. 어택·효과 크러시 모두(FAQ 1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_CRUSH)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end
  -- 트래시에 놓는 것은 크러시가 아니라 버스트는 없다(FAQ 2)
  local e2=Effect.CreateEffect(e:GetHandler())
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EVENT_TURN_END)
  e2:SetReset(RESET_PHASE+PHASE_END)
  e2:SetOperation(function(e2,tp2)
    local top=Duel.GetLifetopGroup(tp2,1)
    if top:GetCount()>0 then Duel.SendToTrash(top,REASON_EFFECT) end
  end)
  Duel.RegisterEffect(e2,tp)
end

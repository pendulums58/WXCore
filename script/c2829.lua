-- WX16-002 救念の記憶　リル
-- 【常】：対戦相手のターンの間、《ライズアイコン》を持つあなたのシグニ１体がバニッシュされる場合、代わりにその下からカード２枚をトラッシュに置いてもよい。
-- 【自】：あなたのターン開始時、《コインアイコン》を得る。（上限は５枚）
-- 【自】《ターン１回》：《ライズアイコン》を持つあなたのシグニ１体が場に出たとき、カードを１枚引く。
-- 【出】／【起】オーネスト《コインアイコン》《コインアイコン》：ターン終了時まで、このターンの前のターンに発動したコイン技を無効にする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「その下からカード２枚をトラッシュに置いてもよい」 대체와 コイン技 무효는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_PHASE_START+PHASE_UP)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetCoin(tp)<5 end)
  e1:SetOperation(function(e,tp)
    Duel.AddCoin(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:HasRiseIcon() end)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end

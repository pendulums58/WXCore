-- WX22-014 共闘の鍵主　ウムル＝フィーラ
-- 【常】：あなたの場に《差し伸べし者　タウィル》がいるかぎり、このルリグのリミットは１増え、このルリグは追加で白と＜タウィル＞を得る。
-- 【自】《ターン１回》：あなたの効果１つによってあなたのトラッシュからカードが４枚以上デッキに移動したとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード１：このルリグのエクシード能力１つをコストを支払わずに使用する。この能力はあなたの場に《差し伸べし者　タウィル》がいる場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「《差し伸べし者　タウィル》がいるかぎりリミット＋1·白と＜タウィル＞」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_MOVED_TO_DECK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EFFECT~=0 and eg:Filter(function(x) return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_TRASH) end,nil):GetCount()>=4 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-8000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  -- 【起】 「エクシード能力１つをコストを支払わずに使用」은 아직(근사 없음)
end

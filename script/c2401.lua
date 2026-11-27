-- WX10-025 ファイブ・レインボー
-- あなたのエナゾーンにあるカードが持つ色から最大５色まで選ぶ。その後、
-- 白を選んだ場合、シグニ１体を対象とし、それを手札に戻す。
-- 赤を選んだ場合、パワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- 青を選んだ場合、カードを２枚引く。
-- 緑を選んだ場合、あなたのデッキの上からカードを２枚エナゾーンに置く。
-- 黒を選んだ場合、シグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 처리할 때 에나의 색에서(FAQ 1·2). 【マルチエナ】는 색이 아니다
  e1:SetOperation(function(e,tp)
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}
    local have={}
    for i,col in ipairs(cols) do have[i]=Duel.GetMatchingGroup(function(x) return x:IsColor(col) end,tp,LOCATION_ENA,0,nil):GetCount()>0 end
    local opts,map={},{}
    for i=1,5 do if have[i] then opts[#opts+1]=aux.Stringid(id,i-1) map[#opts]=i end end
    if #opts==0 then return end
    local pick={}
    for _,k in ipairs(Duel.SelectModes(tp,0,#opts,table.unpack(opts))) do pick[map[k+1]]=true end
    if pick[1] then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.SendToHand(tc) end end
    if pick[2] then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if pick[3] then Duel.Draw(tp,2) end
    if pick[4] then Duel.EnaCharge(tp,2) end
    if pick[5] then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst() if tc then aux.AddPower(e,tc,-12000) end end
  end)
  c:RegisterEffect(e1)
end

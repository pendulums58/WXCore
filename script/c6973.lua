-- WXK09-100 楽隊の童話　キャットレ
-- 【出】：各プレイヤーは自分のデッキの上からカードを２枚トラッシュに置く。その後、この方法でトラッシュに置かれたすべてのカードの中に同じレベルを持つシグニがない場合、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－1000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 뒷부분(대상 상대 시그니 －)은 근사: －3000
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local all=Group.CreateGroup()
    for _,p in ipairs({tp,1-tp}) do
      local g=Duel.GetDecktopGroup(p,2)
      for x in g:Iter() do all:AddCard(x) end
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
    local seen={}
    for x in all:Iter() do
      if x:IsSigni() then
        if seen[x:GetLevel()] then return end
        seen[x:GetLevel()]=true
      end
    end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-1000) end
  end)
  c:RegisterEffect(e1)
end

-- WX12-Re07 レインボーアート
-- あなたのトラッシュからシグニ１枚とスペル１枚を対象とし、それらを手札に加える。その後、この方法で手札に加えたカード１枚につきそのカードに含まれる色１つを選択する。
-- 選択した色に赤を含む場合、対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。緑を含む場合、対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。青を含む場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    local b=Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    local got={}
    for _,x in ipairs({a,b}) do if x and Duel.SendToHand(x)>0 then got[#got+1]=x end end
    local r,gr,u=false,false,false
    for _,x in ipairs(got) do
      local opts,map={},{}
      for i,col in ipairs({COLOR_RED,COLOR_GREEN,COLOR_BLUE}) do if x:IsColor(col) then opts[#opts+1]=aux.Stringid(id,i-1) map[#opts]=i end end
      if #opts>0 then
        local k=map[Duel.SelectModes(tp,1,1,table.unpack(opts))[1]+1]
        if k==1 then r=true elseif k==2 then gr=true else u=true end
      end
    end
    if r then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if gr then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if u then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end

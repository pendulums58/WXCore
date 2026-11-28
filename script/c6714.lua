-- WXK07-012 波乱爆丈
-- アンコール －《コインアイコン》《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- 以下の２つから１つを選ぶ。
-- ①あなたのトラッシュから＜原子＞のシグニを２枚まで対象とし、それらを手札に加える。
-- ②あなたの＜原子＞のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】と【ダブルクラッシュ】を得る。（【アサシン】を持つシグニがアタックすると正面のシグニとバトルをせず対戦相手にダメージを与える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then
      local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end,tp,LOCATION_TRASH,0,0,2,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
      return
    end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc then aux.GrantKeyword(e,tc,EFFECT_ASSASSIN) aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e1)
end

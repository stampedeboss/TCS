
env.info("TCS(A2G.FEEDBACK): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.Feedback = TCS.A2G.Feedback or {}

function TCS.A2G.Feedback.ToGroup(group, text, duration)
  if not group then return end
  MESSAGE:New(text, duration or 10):ToGroup(group)
end

env.info("TCS(A2G.FEEDBACK): ready")

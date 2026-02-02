
env.info("TCS(A2G.FEEDBACK): loading")

TCS.A2G.Feedback = {}

function TCS.A2G.Feedback.ToGroup(group, text, duration)
  if not group then return end
  MESSAGE:New(text, duration or 10):ToGroup(group)
end

env.info("TCS(A2G.FEEDBACK): ready")

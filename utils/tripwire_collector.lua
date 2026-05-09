-- Run this once to extract waypoints to your DCS.log!
for coal_name, coal_data in pairs(env.mission.coalition) do
    if coal_data.country then
        for _, country in ipairs(coal_data.country) do
            -- Search all unit categories so we can use aircraft for over-water lines
            for _, category in ipairs({"vehicle", "helicopter", "plane", "ship"}) do
                if country[category] and country[category].group then
                    for _, group in ipairs(country[category].group) do
                        if group.name == "TRIPWIRE_DUMMY" then
                            env.info("local custom_tripwire_points = {")
                            for _, pt in ipairs(group.route.points) do
                                env.info(string.format("  {x = %.2f, y = %.2f},", pt.x, pt.y))
                            end
                            env.info("}")
                        end
                    end
                end
            end
        end
    end
end

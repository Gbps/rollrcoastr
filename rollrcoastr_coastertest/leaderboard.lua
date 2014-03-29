leaderboard = {}

HORIZ_SPACE = 100

t = {0,0,0,0,0,0,0,0,0}

function leaderboard.updateBoard(score)
	for g = 1, #t, 1 do
		if t[g] == nil or t[g] < score then
			table.insert(t, g, score)
			break
		end
	end
end

function leaderboard.displayBoard()

	love.graphics.print('LEADERBOARD',(WORLDWIDTH/2)-(font:getWidth('LEADERBOARD'))/2,330)
	for f = 1, 5, 1 do
		love.graphics.print(tostring(t[f])..' m',(WORLDWIDTH/2) - 35 - HORIZ_SPACE, 340 + 15 * f)
	end
	for h = 6, 10, 1 do
		love.graphics.print(tostring(t[h]..' m'),(WORLDWIDTH/2) - 35 + HORIZ_SPACE, 340 + 15 * (h - 5))
	end

end
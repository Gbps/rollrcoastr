leaderboard = {}

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
		love.graphics.print(tostring(t[f]),340, 340 + 12 * f)
	end
	for h = 6, 10, 1 do
		love.graphics.print(tostring(t[h]), 440, 340 + 12 * (h - 5))
	end

end
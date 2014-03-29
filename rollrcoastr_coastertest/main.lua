WORLDHEIGHT = 640;
WORLDWIDTH = 960;

require "coasterLib"
require "background"
require "leaderboard"

local afterGame = false;
local beforeGame = true;
titleArray = {'revengeance', 'better than skyrim', 'this game is _unreal_', 'spiritual sequal to minecraft', 'I hope we win', 'voted best game of the year all years', 'this is an easter egg ;)', 'game is hard', 'the hit new moba from Team Rotatoes', 'better than dota', 'a rotatoes production', 'it\'ll make you cry', 'help me', 'the citizen kane of gaming', 'help: trapped in indian game development studio', 'beachball simulator 2014', 'based on a flappy bird meme', 'not based on flappy bird', 'definitely not flappy bird stop asking', 'now featuring bitcoin microtransactions', 'funded by kickstarter', 'funded by indiegogo', 'funded by kickstopper', 'sponsored by olive garden', 'we were paid to put this here', 'Enjoy the fresh taste of MOUNTAIN DEW™ and DORITOES™', 'AAAAAAAAAAAAAAAA', 'sponsored by fisher south', 'flappymemecoasterextreme2012', 'created by Notch', 'the spiritual sequal to potato counter extreme', 'we made this music', 'don\'t tell our parents', 'sherlock isn\'t even that good of a show', 'unemployment.png', 'written with EMACS', 'seriously guys I hope you don\'t do this', 'i\'ve been awake for 36 hours', 'please sponsor us', 'sponsored by razer', 'happy birthday sam coat'}

function love.load()
	math.randomseed( os.time() )
	title = love.graphics.newImage('titlescreen.png')
	end_screen = love.graphics.newImage('Game_over.png')
	love.mouse.setVisible( true )

	song = love.audio.newSource('thesong.mp3')
	song:setLooping(true)
	song:setVolume(0.4)
	song:play()

	love.window.setMode( 960, 640, {})
	love.window.setTitle('rollr coaster - '.. titleArray[math.random(#titleArray)])
	background.load()

end

function love.keypressed(key)
	if key == 'x' and afterGame == true or beforeGame == true then
		coasterLib.startGame()
		love.mouse.setVisible( false )
		beforeGame = false
		afterGame = false

	elseif key == 'm' and afterGame == true then
		beforeGame = true
		afterGame = false
	elseif key == "z" then
		if( love.audio.getVolume() == 1) then
    		love.audio.setVolume( 0 )
    	else
    		love.audio.setVolume( 1 )
    	end
  	end
end

	function coasterLib.GameOver()
		afterGame = true;
		score = coasterLib.XScroll / 32
		leaderboard.updateBoard(math.floor(score))
	end

	function love.update( dt )
		background.update(dt)
		if beforeGame or afterGame then return; end
		coasterLib.update( dt )

		_world:update( dt )
	end

	function love.draw() 
		background.draw()
		if afterGame then 
			displayEnd()
			return; 
		end
		if beforeGame then love.graphics.draw(title) return; end
		coasterLib.onDraw( _world )

	end

	function displayEnd()
		love.graphics.draw(end_screen)
		font = love.graphics.newImageFont("Courier New20pt.png", " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
		love.graphics.setFont(font)
		love.graphics.setColor(0,0,0)
		love.graphics.printf('You went '..tostring(math.floor(score))..' meters!',
			(WORLDWIDTH/2)-(font:getWidth('You went '..tostring(math.floor(score))..' meters!'))/2,
			300,500,center)
		leaderboard.displayBoard(math.floor())
		love.graphics.setColor(255,255,255)
	end

--pong game
push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1200
WINDOW_HEIGHT  = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 385

--comment HERE
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 10)
    scoreFont = love.graphics.newFont('Arcade.ttf', 65)
    love.graphics.setFont(smallFont)


    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = false,
        vsync = true
    })

    --importing sounds
    --ball hits paddle sound
    sound1 = love.audio.newSource("ball1.mp3", "stream")
    --ball hits wall sound
    sound2 = love.audio.newSource("ball2.mp3", "stream")
    --player wins
    win = love.audio.newSource("win.mp3", "stream")
    --lose point sound
    lose= love.audio.newSource("lose.mp3", "stream")

    --initializing paddleslove.graphics.setColor(0, 100, 0, 100)
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH -10, VIRTUAL_HEIGHT-50, 5,  20)


    --initializing ball
    ball = Ball(VIRTUAL_WIDTH / 2-2, VIRTUAL_HEIGHT/2-2, 4, 4)

    --initializing score
    player1Score = 0
    player2Score = 0

    --whos turn is it initializing variable 
    servingPlayer = 1

    --initializing game status
    gameState = 'start'

end

function love.keypressed(key)
    --quit game
    if key == 'escape' then
        love.event.quit()
    --start the game
    elseif key == 'enter' or key == 'return' then
        
        if gameState == 'start' then
            gameState = 'serve'
        
        elseif gameState == 'serve' then
            gameState = 'play'
        
        elseif gameState == 'done' then
            
            --gane reset
            gameState = 'serve'
        
            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else 
                servingPlayer = 1
            end

            --[[ballX = VIRTUAL_WIDTH / 2-2 
            ballY = VIRTUAL_HEIGHT/2-2

            ballDX = math.random(2) == 1 and 100 or -100
            ballDY =math.random(-50, 50)]]

        end
    end
end

function love.update(dt)

    if gameState == 'serve' then
        
        if servingPlayer == 1 then
            ball.dx = math.random(-220, 220)
        else 
            ball.dx = -math.random(-220, 220)
        end
        ball.dy = math.random(-200, 200)

    elseif gameState == 'play' then
        
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            --ball hits wall sound
            love.audio.play(sound2)
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            --ball hits wall sound
            love.audio.play(sound2)
        end

        if ball:collides(player1) then
            --increase on speed
            ball.dx = -ball.dx * 1.175 --change the .# to increase speed 
            ball.x = player1.x + 5
            love.audio.play(sound1)

            if ball.dy < 0 then 
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end

        end

        if ball:collides(player2) then
            --increase on speed
            ball.dx = -ball.dx * 1.175
            ball.x = player2.x - 4
            love.audio.play(sound1)

            if ball.dy < 0 then 
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end
        end
    end

    if ball.x < 0 then
        
        --lose sound
        love.audio.play(lose)

        player2Score = player2Score + 1
        servingPlayer = 2
        
        if player2Score == 3 then
           
            winningPlayer = 2
            --winner sound 
            love.audio.play(win)
            gameState = 'done'
            
        
        else
            gameState = 'serve'
        
        end
        ball:reset()
    end

    if ball.x > VIRTUAL_WIDTH then
        
        --lose sound
        love.audio.play(lose)

        player1Score = player1Score + 1
        servingPlayer = 1
        
        if player1Score == 3 then
            
            winningPlayer = 1
            --winner sound
            love.audio.play(win)
            gameState = 'done'
            
        
        else
            gameState = 'serve'
        
        end
        ball:reset()
    end

    -- up and down of left paddle
    if love.keyboard.isDown('w') then
        --changing coordinates
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s')then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0

    end

    --up and down of right paddle
    if love.keyboard.isDown('up') then
        --changing coordinates
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down')then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    --dt updates with frames its a constant depending on the sreen Hz
    if gameState == 'play' then
        ball:update(dt)
        --ballX = ballX + ballDX * dt
        --ballY = ballY + ballDY * dt
    end
    --update coordinates
    player1:update(dt)
    player2:update(dt)

end

function love.draw()
    
    push:apply("start")

    --tiitle
    --setColor(red, green, blue, alpha)
    love.graphics.setColor(0, 100, 0, 100)
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Hello welcome to Pong!', 0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "Enter" to start', 0, 125, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('Player' .. tostring(servingPlayer)..' serve', 0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "Enter" to serve!', 0, 125 , VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        --no message 
    elseif gameState == 'done' then
        love.graphics.printf('Player'..tostring(winningPlayer)..'wins!', 0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "Enter" to start new game.', 0, 125, VIRTUAL_WIDTH, 'center')
    end

    --score tiitle
    --setColor(red, green, blue, alpha)
    love.graphics.setColor(0, 100, 0, 100)
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 -50, VIRTUAL_HEIGHT/7)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 +30, VIRTUAL_HEIGHT/7)

    player1:render()
    player2:render()
    ball:render()
    
    --paddles
    --[[love.graphics.setColor(0, 100, 0, 100)
    love.graphics.rectangle('fill', 10, player1Y, 5,  20)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH -10, player2Y, 5,  20)
    --ball
    love.graphics.rectangle('fill', ballX, ballY, 4, 4)]]

    push:apply("end")

end
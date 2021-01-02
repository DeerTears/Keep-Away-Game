# Keep Away Game (out now!)
A 3D local multiplayer prototype about whacking balls for points, made in Godot. 

go check out the 1.1 prototype on itch.io!
https://deertears.itch.io/keep-away-prototype
https://deertears.itch.io/keep-away-prototype
https://deertears.itch.io/keep-away-prototype

I started this project on December 1st 2020, published this repo December 15th 2020, and released my first build on itch.io January 1st 2021. This may be my most successfully managed prototype-type project yet.

<!-- <img src="/docs/images/2020-12-16_editor.jpg" alt="Screenshot of Editor Prototype Level"/> -->

![Screenshot of Editor Prototype Level](/docs/images/2020-12-16_editor.jpg)

![Screenshot of Player Throwing Metal Ball in Prototype Level](/docs/images/2020-12-16_ingame0.jpg)

![Screenshot of Player looking at other Player](/docs/images/2020-12-16_ingame1.jpg)

This is the largest coding project I've ever taken on, and I've already restarted the project twice. I consider my custom classes and statemachines to be okay, but the scoring code, the UI code, and the reliance on a Singleton need to be broken down and simplified.

I've had too many unplanned ideas during the creation of this prototype and I did not hesitate to introduce new, unfinished gamemodes that are still lingering in the code right now. Hopefully I can take some time to refactor this project (in a clean folder, restarting the project a third time) so it's even more streamlined and easier to work with.

# Current Gamemodes

## Graffiti
- hit balls to colour them for your team
- hit balls of your opponent's colour to recolour it and steal it back
- whoever has the most balls at the end of the game wins

## Soccer?
- hit balls into anyone's goal to win
- whoever scores the most goals at the end wins

note: ScoreZones as a parent of area nodes denotes them as soccer-scoring zones. remember to enable "worldtriggers" physics layer as well

## Keep Away (broken)
- i should probably rename this project since this gamemode doesn't work yet
- there is no logic for this yet unfortunately

My inspiration for this game was initially [Potion Wolf](https://bitzawolf.itch.io/potion-wolf), an arcade singleplayer game about combining potions under a time limit. I wanted to create a FPS multiplayer splitscreen version of it after seeing some Goldeneye splitscreen multiplayer footage. After a failed attempt to make a potion-combining game, what I ended up with was instead a game about whacking balls in first person to score points. I am looking to cartoony sportsy games as my next set of inspirations.

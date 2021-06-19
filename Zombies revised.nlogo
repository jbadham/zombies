breed [humans human]  ;; plural then singular name for the breed of turtle.
breed [zombies zombie]
zombies-own
[ next-state      ; state for next timestep
  H-found         ; how many humans seen
]
humans-own
[ next-state      ; state for next timestep
  Z-found         ; how many zombies seen
  skill           ; skill in in killing zombies
]
patches-own
[ hz-ratio          ;; number of humans / number of zombies
]

to setup
  clear-all
  ask patches [ set pcolor white ]
  ;; create agents, randomly locate
  set-default-shape turtles "person"
  create-zombies round (initial-zombie-density * count patches)
  [ set color blue set size 0.5
    setxy random-xcor random-ycor
  ]
  create-humans round (initial-human-density * count patches)
  [ set color red set size 0.5
    set skill initial-skill
    setxy random-xcor random-ycor
  ]
  reset-ticks
end

to go
  if not any? zombies or not any? humans [stop]
  move
  fight
  tick
end

to move
  ; zombies face largest number of humans in cardinal directions
  ask zombies
  [ set heading one-of [0 90 180 279]            ; random direction if no humans
    set H-found 0
    let H-looking 0
    set H-looking count humans-on (patch-set patch-at 0 1 patch-at 0 2 patch-at 0 3)  ; up
    if H-looking > H-found
    [ set H-found H-looking
      set heading 0
    ]
    set H-looking count humans-on (patch-set patch-at 0 -1 patch-at 0 -2 patch-at 0 -3)  ; down
    if H-looking > H-found
    [ set H-found H-looking
      set heading 180
    ]
    set H-looking count humans-on (patch-set patch-at 1 0 patch-at 2 0 patch-at 3 0)   ; right
    if H-looking > H-found
    [ set H-found H-looking
      set heading 90
    ]
    set H-looking count humans-on (patch-set patch-at -1 0 patch-at -2 0 patch-at -3 0) ; left
    if H-looking > H-found
    [ set H-found H-looking
      set heading 270
    ]
  ]
  ; humans face away from largest number of zombies in cardinal directions
  ask humans
  [ set heading one-of [0 90 180 279]            ; random direction if no zombies
    set Z-found 0
    let Z-looking 0
    set Z-looking count zombies-on (patch-set patch-at 0 1 patch-at 0 2 patch-at 0 3)  ; up
    if Z-looking > Z-found
    [ set Z-found Z-looking
      set heading 180
    ]
    set Z-looking count zombies-on (patch-set patch-at 0 -1 patch-at 0 -2 patch-at 0 -3)  ; down
    if Z-looking > Z-found
    [ set Z-found Z-looking
      set heading 0
    ]
    set Z-looking count zombies-on (patch-set patch-at 1 0 patch-at 2 0 patch-at 3 0)   ; right
    if Z-looking > Z-found
    [ set Z-found Z-looking
      set heading 270
    ]
    set Z-looking count zombies-on (patch-set patch-at -1 0 patch-at -2 0 patch-at -3 0) ; left
    if Z-looking > Z-found
    [ set Z-found Z-looking
      set heading 90
    ]
  ]
  ; Humans move 1 patch if no zombies visible, else run at highest speed
  ask humans
  [ ifelse Z-found = 0
    [ forward 1 ]
    [ forward human-speed ]
  ]
  ; Zombies always move 1 patch
  ask zombies [ forward 1 ]
end

to fight
  ; any patch with both Humans and Zombies, each H fights with each Z
  ask patches with [ any? humans-here and any? zombies-here ]    ; patch has both humans and zombies
  [ set hz-ratio count humans-here / count zombies-here          ; calculate relative numbers
    ; each human-zombie pair fights
    ask humans-here
    [ ask zombies-here
      [ ; outcome is random based on human's skill and relative numbers of Zombies and Humans
        ifelse random-float 1 < [skill] of myself * hz-ratio
        [ ; Human wins, Z to die and H increase skill
          set next-state "D"
          ask myself [ set skill skill + skill-increment ]
        ]
        [ ; Zombie wins, H to become Zombie
          ask myself [set next-state "Z" ]
        ]                        ;
      ]
    ]    ; end all fights on the patch
  ]      ; end all patches with Humans and Zombies
  ; Convert Humans who lost at least one fight to Zombies
  ask humans with [next-state = "Z"]
  [ set breed zombies
    set color blue
  ]
  ; Remove Zombies who lost at least one fight
  ask zombies with [next-state = "D"] [ die ]
end

@#$#@#$#@

SLIDER
40
30
210
63
initial-human-density
initial-human-density
0
1
0.6
0.05
1
NIL
HORIZONTAL

SLIDER
40
63
210
96
initial-zombie-density
initial-zombie-density
0
1
0.35
0.05
1
NIL
HORIZONTAL

SLIDER
220
30
390
63
initial-skill
initial-skill
0
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
220
63
390
96
skill-increment
skill-increment
0
0.2
0.05
0.025
1
NIL
HORIZONTAL

SLIDER
220
96
390
129
human-speed
human-speed
1
5
5.0
1
1
NIL
HORIZONTAL

BUTTON
430
30
530
80
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
430
80
530
130
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
430
130
530
180
step once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
40
180
390
452
Population Counts
Time
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"H" 1.0 0 -2674135 true "" "plot count humans"
"Z" 1.0 0 -13345367 true "" "plot count zombies"

MONITOR
450
254
510
299
Humans
count humans
0
1
11

MONITOR
450
303
510
348
Zombies
count zombies
0
1
11

GRAPHICS-WINDOW
570
23
998
452
-1
-1
20.0
1
10
1
1
1
0
1
1
1
-10
10
-10
10
1
1
1
ticks
30.0

@#$#@#$#@
## WHAT IS IT?

This model examines the spread of a zombie infestation. It was developed to investigate whether the superior speed of uninfected humans and their capacity to improve as they gain fighting experience enables humans to survive despite apparently overwhelming odds.

The world is conceptualised as a city, with streets laid out on a grid. Visibility and movement are restricted to vertical and horizontal directions along those streets, with wrapping. The world's patches represent the intersections of those streets. Fights occur between humans and zombies wherever both types of agents share an intersection. A winning human kills a zombie, and a losing human becomes a zombie.

## HOW IT WORKS

There are two types of agents: uninfected humans (red figures, H on chart) and zombies (blue figures, Z on chart). Available directions are restricted to vertical (up/down or North/South) and horizontal (left/right or East/West).

Two distinct processes occur each timestep. First, all the agents choose a direction and move. Second, wherever humans and zombies share a patch after the movement, the humans fight and zombies fight.

MOVEMENT: Each agent is able to see 3 patches in any (vertical or horizonal) direction. Zombies look for humans and choose their direction to move toward the largest number of humans (or random direction if no humans are visible). Humans look for zombies and choose their direction to move away from the largest number of zombies (or random direction if no zombies are visible). Once all the humans and zombies have chosen their direction, they move forward (that is, synchronous movement). Zombies move one patch. Humans walk one patch if they did not see any zombies, or run a number of patches (set by speed) if they did see zombies. If humans and zombies cross while moving, they ignore each other.

FIGHTING: Combat occurs after all agents have moved. The combat is between all zombie-human pairs on each patch with both types of agents. For example, if there are 3 zombies and 2 humans on a patch, there are 6 fights for that patch. For each fight, a pseudo-random number is generated in the interval [0,1). If that number is less than the human's modified skill, then the human wins. The modified skill is the skill of the human multiplied by the ratio humans / zombies on the patch (to recognise the effects of outnumbering). If the human wins, the human's skill immediately increases by the skill-increment value and the zombie is marked for death. If the zombie wins, the human is marked for zombification. After all fights are completed, zombies marked for death are die, and humnas marked for zombification become zombies.

## THINGS TO NOTICE

The model can exhibit three types of results: humans winning, zombies winning and stalemate. Stalemate is of two types. Where the humans have the same speed as the zombies, groups of zombies can chase groups of humans forever. For faster humans, the possible stalemate is of the form of oscillation between two configurations, where humans move one way to avoid zombies and then return to their previous position to avoid a new group of zombies.

With some level of initial skill and skill increments, if some humans survive the initial fights, they can eventually defeat all zombies. This occurs generally where initially outnumber zombies.

Some input parameters likely to get specific results are:  
Zombie win: Humans 0.1, Zombies 0.85, Skill 0.3, Increment 0.05, Speed 3  
Human fast win: Humans 0.85, Zombies 0.1, Skill 0.4, Increment 0.1, Speed 3  
Human slow win: Humans 0.85, Zombies 0.1, Skill 0.3, Increment 0.05, Speed 3  
Chase groups:  Humans 0.85, Zombies 0.1, Skill 0.3, Increment 0.05, Speed 5 (less common, you may need several simulations before the behaviour occurs)

## EXTENDING THE MODEL

One area of the model that could be made significantly more realistic is the intelligence of the humans in choosing their movement. They are only able to run away at maximum speed. Other possibilities include moving toward other humans to take advantage of group protection, and moving toward isolated or small groups of zombies once the human is sufficiently skilled to successfully attack.

## CREDITS AND REFERENCES

This model was developed by Jennifer Badham (research@criticalconnections.com.au) in February 2010. It is described in the book chapter:

Badham JM and Osborn J, "Zombies in the City: a Netlogo Model" in <editor, book title, publisher, pages>

with detailed results available at <URL>. <book title> is inspired by:

Philip Munz, Ioan Hudea, Joe Imad and Robert J Smith? In: `Infectious Disease Modelling  
Research Progress' Nova Sciences Publishers Inc (2009), pp 133-150
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="popn-density-speed1" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>count zombies</metric>
    <metric>count humans</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="initial-skill">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-zombie-density" first="0" step="0.05" last="1"/>
    <enumeratedValueSet variable="human-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="skill-increment">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-human-density" first="0" step="0.05" last="1"/>
  </experiment>
  <experiment name="popn-density-speed2+" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2500"/>
    <metric>count zombies</metric>
    <metric>count humans</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="initial-skill">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-zombie-density" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="human-speed" first="2" step="1" last="5"/>
    <enumeratedValueSet variable="skill-increment">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-human-density" first="0" step="0.05" last="1"/>
  </experiment>
  <experiment name="world-size" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count zombies</metric>
    <metric>count humans</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="initial-skill">
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-zombie-density" first="0.15" step="0.7" last="0.85"/>
    <enumeratedValueSet variable="human-speed">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="skill-increment">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-human-density" first="0.15" step="0.7" last="0.85"/>
  </experiment>
  <experiment name="skill" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count humans</metric>
    <metric>count zombies</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="human-speed">
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-zombie-density">
      <value value="0.005"/>
      <value value="0.15"/>
      <value value="0.5"/>
      <value value="0.85"/>
    </enumeratedValueSet>
    <steppedValueSet variable="skill-increment" first="0" step="0.05" last="0.2"/>
    <steppedValueSet variable="initial-skill" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="initial-human-density">
      <value value="0.15"/>
      <value value="0.5"/>
      <value value="0.85"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="popn-density-speed2+-skill" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2500"/>
    <metric>count zombies</metric>
    <metric>count humans</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="initial-skill">
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-zombie-density" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="human-speed" first="2" step="1" last="5"/>
    <enumeratedValueSet variable="skill-increment">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-human-density" first="0" step="0.05" last="1"/>
  </experiment>
  <experiment name="popn-density-speed1-skill" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count zombies</metric>
    <metric>count humans</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="initial-skill">
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-zombie-density" first="0" step="0.05" last="1"/>
    <enumeratedValueSet variable="human-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="skill-increment">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-human-density" first="0" step="0.05" last="1"/>
  </experiment>
  <experiment name="full-runs" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count humans</metric>
    <metric>count zombies</metric>
    <enumeratedValueSet variable="initial-skill">
      <value value="0"/>
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="skill-increment">
      <value value="0"/>
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-zombie-density">
      <value value="0.05"/>
      <value value="0.5"/>
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-human-density">
      <value value="0.05"/>
      <value value="0.5"/>
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human-speed">
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="low-Z-densities" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2500"/>
    <metric>count humans</metric>
    <metric>count zombies</metric>
    <enumeratedValueSet variable="initial-skill">
      <value value="0"/>
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-human-density" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="initial-zombie-density" first="0" step="0.005" last="0.05"/>
    <enumeratedValueSet variable="skill-increment">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human-speed">
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

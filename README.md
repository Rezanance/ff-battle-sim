# Fossil Fighters: Champions battle sim

## Entity composition 
? = optional

Screens
- Title scene
- Team setup scene
- Match finder scene (rando or known user)
- Battle formation screen (Look at oppenents vivosaurs, change formation 
and choose 3/5 in team)
- Battle scene
- Results scene

### Battle scene (where the whole battle takes place )
Battle Manager
- GUI
- Arena

GUI
- Your FP
- Opponents FP
- Vivosaur Select (yours and the opponents)
- End turn
- Rotate left
- Rotate Right
- Use Skill

Arena
- Your zones
- Opponent zones

Zone
- Vivosaur?

Vivosaur
- id
- Name
- Element
- Stats (LP, attack ,..., crit rate)
- Super revival stats
- Skills (including passive skills)
- Support effects
- Status effects (Increased defense, poision, ...)
- Attack range (close, mid or long)
- Status immunities
- team skill groups

Skills
- id
- Name
- Skill type (damage, neutral, positive, passive, team skill)
- Damage
- FP cost
- Effects
- Counterable
- 

Effect
- id
- Description

Status
- id
- Description
- Turns active


#### Type of effects 
- Stat boost
- Damage per turn

Nationstate Phase 1 & 2: Core Game Loop and Economy System  
Design Documentation

**Purpose:**   
Create the core turn based system, a usable UI, and a basic economic model with updates each turn.

**Scope:**  
Included:  
\- Basic UI dashboard  
\- Turn progression button  
\- Central GameState  
\- Simple economic variables  
\- Per-turn updates

Not Included:  
\- Player actions  
\- Events  
\- Elections  
\- Save/load

**Core Systems**  
UI:  
\- Displays all buttons for future action implementation  
\- Displays important data such as year, quarter, GDP, and population on a panel  
\- Contains large Next Quarter button to progress game  
Next Quarter Button:  
\- Progresses to next year or quarter  
\- Updates economic model  
\- Updates labels  
Economic System:  
\- Basic economic system consists of a set of starting variables and modifier variables  
\- Starting variables set initial starting values for economic data  
	\- GDP  
	\- population  
	\- unemployment  
	\- literacy  
	\- SOL (Standard Of Living)  
	\- Class dictionary (Contains what percentage of population is in each class)  
	\- Urbanization dictionary (What percentage of pop is in each urbanization level)  
\- Modifier values are to be changed by player decisions which affect starting variables  
	\- Inflation  
	\- Trade (as a percentage of GDP)  
	\- Literacy rate of change  
	\- Birth rate  
	\- Death rate

**Rules:**  
\- Values update deterministically each turn  
\- No player input yet  
\- Changes are small and predictable
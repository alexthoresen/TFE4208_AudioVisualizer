-------------------------------------------------------------------
-- (c) copyright odd tjore, 2000, all rights reserved            --
-------------------------------------------------------------------
-- this code is the property of odd tjore,                       --
-- dept of physical electronics, ntnu, 7034 trondheim, norway    --
-------------------------------------------------------------------
-- module.....: fsm.vhd                                          --
-- language...: vhdl                                             --
-- designer...: odd tjore                                        --
-- date.......: july 21, 2000                                    --
-- task:......: this module is the fsm for a 16 bit two's        --
--              complement multiplier                            --
--
-- In this version of the code, the design is completed
-- NTNU, October 7, 2008, PGK
-------------------------------------------------------------------

-- "library" forteller hvilket funksjonsbibliotek vi oensker aa bruke
-- "use" forteller hvilke deler av dette biblioteket som benyttes

library IEEE;
use IEEE.std_logic_1164.all;


-- "entity" definerer tilstandsmaskinens grensesnitt i form av innganger og utganger

entity mul_fsm is

    port (MTOR_LSB : in  STD_LOGIC; -- 1 bit, lsb from multiplicator register
          START_FSM: in  STD_LOGIC; -- 1 bit, signal to start the fsm, active high
          ZERO     : in  STD_LOGIC; -- 1 bit, zero detection from down counter
          CLK      : in  STD_LOGIC; -- 1 bit, system clock
          RESET_N    : in  STD_LOGIC; -- 1 bit, system reset, active low
           

-- **** HER MANGLER ET UTGANGSSIGNAL SOM MAA LEGGES TIL ****

          DEC      : out STD_LOGIC; 
          LSL      : out STD_LOGIC; -- 1 bit, shift left command to multiplicand register
          LSR      : out STD_LOGIC; -- 1 bit, shift right command to multiplicator register
          TWOC     : out STD_LOGIC; -- 1 bit, two's complement command to adder
          LOAD_DO  : out STD_LOGIC; -- 1 bit, load command to output register
          RESET_DO : out STD_LOGIC; -- 1 bit, reset command to output register
          LOAD_DCNT: out STD_LOGIC  -- 1 bit, load command to down counter
         );
         
end mul_fsm;


-- "architecture" beskriver innholdet i en entity

architecture fsm_arch of mul_fsm is


-- "constant" gir verdier til navn, i dette tilfellet navngis de to tilstandene IDLE og OPERATE

constant IDLE   : STD_LOGIC := '0';
constant OPERATE: STD_LOGIC := '1';


-- "signal" definerer signaler og registere i designet. I dette tilfellet trenger vi et 1-bit register for tilstanden

signal state: STD_LOGIC; -- 1 bit state register


-- Etter "begin" beskrives logikken i tilstandsmakinenen

begin

-- Foelgende prosessdeklarasjon forteller at for hver endring i signalet "CLK" trigges prosessen
-- Denne prosessen styrer overgangen mellom tilstandene

process (CLK) is begin

    if (CLK'event and CLK = '1') then				-- dersom vi har en positiv klokkeflanke...
        if (RESET_N = '0') then
            state <= IDLE;					-- dersom reset er 0, gaa til IDLE					
        elsif ((state = IDLE) and (START_FSM = '1')) then
            state <= OPERATE;					-- osv...
        elsif ((state = OPERATE) and (ZERO = '0')) then
            state <= OPERATE;
        elsif ((state = OPERATE) and (ZERO = '1')) then
            state <= IDLE;
        else
            state <= IDLE;
        end if;
    end if;

end process;

-- Denne prosessen setter tilstandsmaskinens kontrollsignaler avhengig av tilstanden og inngangssignalene

process (state, START_FSM, ZERO, MTOR_LSB) is begin

-- Hver if-linje som innleder en blokk med kontrollsignaler tilsvarer forgreningsflyten i tilstandsdiagrammet
-- Hver blokk med kontrollsignaler tilsvarer en blokk i tilstandsdiagrammet
-- I tillegg kommer den siste blokken i denne prosessen, som for ryddighets skyld setter alle kontrollsignaler
-- til null dersom ingen av de andre tilfellene skulle inntreffe
-- En av blokkene med kontrollsignaler maa endres fullstendig slik det er beskrevet lenger ned
-- I tillegg maa et ukjent kontrollsignal gis verdier I ALLE blokkene

    if ((state = IDLE) and (START_FSM = '1')) then
        LSL       <= '0';
        LSR       <= '0';
        TWOC      <= '0';
        LOAD_DO   <= '0';
        RESET_DO  <= '1';
        LOAD_DCNT <= '1';
        DEC       <= '0';

    elsif ((state = OPERATE) and (ZERO = '0') and (MTOR_LSB = '0')) then
        LSL       <= '1';
        LSR       <= '1';
        TWOC      <= '0';
        LOAD_DO   <= '0';
        RESET_DO  <= '0';
        LOAD_DCNT <= '0';
        DEC       <= '1';
    
    elsif ((state = OPERATE) and (ZERO = '0') and (MTOR_LSB = '1')) then

-- I FØLGENDE BLOKK SKAL KONTROLLSIGNALENE ENDRES (alle er foreløpig bare satt til 0):
-- *** BLOKK FOR ENDRING - START ***

-- Kontrollsignalene er foreloepig satt til 0, men maa endres for at multiplikatoren skal fungere korrekt

        LSL       <= '1'; -- UKJENT
        LSR       <= '1'; -- UKJENT
        TWOC      <= '0'; -- UKJENT
        LOAD_DO   <= '1'; -- UKJENT
        RESET_DO  <= '0'; -- UKJENT
        LOAD_DCNT <= '0'; -- UKJENT
        DEC       <= '1';

-- *** BLOKK FOR ENDRING - SLUTT ***

    elsif ((state = OPERATE) and (ZERO = '1') and (MTOR_LSB = '0')) then
        LSL       <= '0'; -- don't care
        LSR       <= '0'; -- don't care
        TWOC      <= '0'; -- don't care
        LOAD_DO   <= '0';
        RESET_DO  <= '0';
        LOAD_DCNT <= '0'; -- don't care
        DEC       <= '0';

    elsif ((state = OPERATE) and (ZERO = '1') and (MTOR_LSB = '1')) then
        LSL       <= '0'; -- don't care
        LSR       <= '0'; -- don't care
        TWOC      <= '1';
        LOAD_DO   <= '1';
        RESET_DO  <= '0';
        LOAD_DCNT <= '0'; -- don't care
        DEC       <= '0';

    else
        LSL       <= '0';
        LSR       <= '0';
        TWOC      <= '0';
        LOAD_DO   <= '0';
        RESET_DO  <= '0';
        LOAD_DCNT <= '0';
        DEC       <= '0';

    end if;

end process;

end fsm_arch;
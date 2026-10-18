LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY latch1 IS
    PORT ( A            : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   -- 8-bit data in
           Resetn, Clock: IN  STD_LOGIC;                      -- async-ish reset + clock
           Q            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) ); -- 8-bit data out
END latch1;

ARCHITECTURE Behavior OF latch1 IS
BEGIN
    PROCESS ( Resetn, Clock )
    BEGIN
        IF Resetn = '0' THEN
            Q <= "00000000";
        ELSIF Clock'EVENT AND Clock = '1' THEN
            Q <= A;
        END IF;
    END PROCESS;
END Behavior;

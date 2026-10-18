LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fsm IS
    PORT ( clk, reset   : IN  STD_LOGIC;
           current_state: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- to 4x16 decoder
           student_id   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ); -- current ID digit
END fsm;

ARCHITECTURE Behavior OF fsm IS
    SIGNAL y     : UNSIGNED(3 DOWNTO 0) := "0000";  -- state register (0..8)
    SIGNAL y_slv : STD_LOGIC_VECTOR(3 DOWNTO 0);    -- state as slv (for lookup)
BEGIN
    -- next-state: simple up-count 0->8 then wrap to 0
    PROCESS ( clk, reset )
    BEGIN
        IF reset = '0' THEN
            y <= "0000";
        ELSIF clk'EVENT AND clk = '1' THEN
            IF y = 8 THEN          -- state 8 is the last
                y <= "0000";
            ELSE
                y <= y + 1;
            END IF;
        END IF;
    END PROCESS;

    current_state <= STD_LOGIC_VECTOR(y);
    y_slv         <= STD_LOGIC_VECTOR(y);

    -- ID-digit lookup for student number 501312123
    WITH y_slv SELECT
        student_id <= "0101" WHEN "0000",   -- 5
                      "0000" WHEN "0001",   -- 0
                      "0001" WHEN "0010",   -- 1
                      "0011" WHEN "0011",   -- 3
                      "0001" WHEN "0100",   -- 1
                      "0010" WHEN "0101",   -- 2
                      "0001" WHEN "0110",   -- 1
                      "0010" WHEN "0111",   -- 2
                      "0011" WHEN "1000",   -- 3
                      "0000" WHEN OTHERS;
END Behavior;
